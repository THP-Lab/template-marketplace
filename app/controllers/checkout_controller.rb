class CheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart

  def profile
    @cart_products = @cart.cart_products.includes(:product)
    @missing_attributes = current_user.missing_profile_fields
    @cart_pricing = CartPricing.new(@cart_products).summary
  end

  def create
    unless profile_complete_for_checkout?
      redirect_to checkout_profile_path, alert: @profile_alert and return
    end

    cart_products = @cart.cart_products.includes(:product)
    if cart_products.empty?
      redirect_to root_path, alert: "Votre panier est vide." and return
    end

    pricing = CartPricing.new(cart_products).summary

    cart_snapshot = cart_products.map do |cp|
      unit_price = cp.unit_price || cp.product.price
      {
        product_id: cp.product_id,
        quantity: cp.quantity.to_i,
        unit_price: unit_price.to_d.to_s("F"),
        unit_weight: cp.unit_weight_value.to_s("F"),
        selected_options: cp.selected_options_list,
        selected_options_signature: cp.selected_options_signature
      }
    end

    line_items = cart_products.map.with_index do |cp, index|
      option_suffix = cp.selected_options_label.presence
      product_name = [cp.product.title, option_suffix].compact.join(" - ")

      {
        price_data: {
          currency: "eur",
          product_data: { name: product_name },
          unit_amount: (cart_snapshot[index][:unit_price].to_d * 100).to_i
        },
        quantity: cart_snapshot[index][:quantity]
      }
    end

    if pricing.shipping_amount.positive?
      line_items << {
        price_data: {
          currency: "eur",
          product_data: {
            name: "Frais de port"
          },
          unit_amount: (pricing.shipping_amount * 100).to_i
        },
        quantity: 1
      }
    end

    checkout_session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: line_items,
      mode: "payment",
      client_reference_id: current_user.id.to_s,
      # Utilise le placeholder Stripe non encodé pour que l'ID soit substitué
      success_url: "#{checkout_success_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: root_url + "?canceled=true"
    )

    checkout_snapshots[checkout_session.id] = {
      items: cart_snapshot,
      items_amount: pricing.items_total.to_s("F"),
      shipping_amount: pricing.shipping_amount.to_s("F"),
      shipping_weight: pricing.total_weight.to_s("F"),
      total_amount: pricing.total_amount.to_s("F")
    }

    redirect_to checkout_session.url, allow_other_host: true
  end

  def success
    session_id = params[:session_id]
    unless session_id
      redirect_to root_path, alert: "Session de paiement manquante." and return
    end

    checkout_session = Stripe::Checkout::Session.retrieve(session_id)
    unless checkout_session.payment_status == "paid"
      redirect_to root_path, alert: "Paiement non confirmé." and return
    end

    unless checkout_session.client_reference_id.to_i == current_user.id
      redirect_to root_path, alert: "Session de paiement invalide." and return
    end

    if order_for_processed_checkout(session_id)
      redirect_to user_path(current_user), notice: "Paiement déjà confirmé pour cette session." and return
    end

    snapshots = checkout_snapshots
    cart_snapshot = snapshots.delete(session_id)
    session[:checkout_snapshots] = snapshots
    unless cart_snapshot.present?
      redirect_to root_path, alert: "Impossible de finaliser la commande: panier introuvable pour cette session." and return
    end

    order = create_paid_order_from_snapshot(cart_snapshot)
    unless order
      redirect_to root_path, alert: "Impossible de finaliser la commande: éléments invalides." and return
    end

    processed_orders = processed_checkout_orders
    processed_orders[session_id] = order.id
    session[:processed_checkout_orders] = processed_orders
    current_user.cart.cart_products.destroy_all

    redirect_to user_path(current_user), notice: "Paiement confirmé, panier vidé."
  end

  private

  def checkout_snapshots
    session[:checkout_snapshots] ||= {}
  end

  def processed_checkout_orders
    session[:processed_checkout_orders] ||= {}
  end

  def order_for_processed_checkout(session_id)
    order_id = processed_checkout_orders[session_id]
    return unless order_id

    current_user.orders.find_by(id: order_id)
  end

  def create_paid_order_from_snapshot(snapshot)
    snapshot_hash = snapshot.is_a?(Hash) ? snapshot.with_indifferent_access : { items: Array(snapshot) }
    items = Array(snapshot_hash[:items])
    pricing = CartPricing.new(items).summary
    items_amount = snapshot_hash[:items_amount].presence&.to_d || pricing.items_total
    shipping_amount = snapshot_hash[:shipping_amount].presence&.to_d || pricing.shipping_amount
    shipping_weight = snapshot_hash[:shipping_weight].presence&.to_d || pricing.total_weight
    order = nil

    Order.transaction do
      order = current_user.orders.create!(
        order_date: Time.current,
        status: "paid",
        total_amount: 0,
        items_amount: 0,
        shipping_amount: shipping_amount,
        shipping_weight: shipping_weight
      )

      computed_items_amount = 0.to_d

      items.each do |item|
        product = Product.find_by(id: item["product_id"] || item[:product_id])
        next unless product

        quantity = (item["quantity"] || item[:quantity]).to_i
        next if quantity <= 0

        unit_price_value = item["unit_price"] || item[:unit_price]
        unit_price = unit_price_value.to_d
        unit_weight = (item["unit_weight"] || item[:unit_weight]).to_d

        order.order_products.create!(
          product: product,
          quantity: quantity,
          unit_price: unit_price,
          unit_weight: unit_weight,
          selected_options: item["selected_options"] || item[:selected_options] || [],
          selected_options_signature: item["selected_options_signature"] || item[:selected_options_signature] || "base"
        )

        computed_items_amount += unit_price * quantity
      end

      if order.order_products.empty?
        order = nil
        raise ActiveRecord::Rollback
      end

      final_items_amount = items_amount.presence || computed_items_amount
      order.update!(
        items_amount: final_items_amount,
        shipping_amount: shipping_amount,
        shipping_weight: shipping_weight,
        total_amount: final_items_amount + shipping_amount
      )
    end

    order
  end

  def profile_complete_for_checkout?
    return true if current_user.profile_complete?

    missing = current_user.missing_profile_fields.map { |field| User.human_attribute_name(field) }
    @profile_alert = "Merci de compléter votre profil (#{missing.join(', ')}) avant de passer au paiement."
    false
  end

  def set_cart
    @cart = current_user.cart
  end
end
