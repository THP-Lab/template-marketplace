class CheckoutController < ApplicationController
  def create
    cart = current_user.cart
    cart_products = cart.cart_products.includes(:product)

    # Calcule le total et crée une commande liée à l'utilisateur
    total_amount = cart_products.sum { |cp| cp.quantity * cp.unit_price }
    order = current_user.orders.create!(
      order_date: Time.current,
      status: "pending",
      total_amount: total_amount
    )

    # Conserve une trace des produits de la commande
    cart_products.each do |cp|
      order.order_products.create!(
        product: cp.product,
        quantity: cp.quantity,
        unit_price: cp.unit_price
      )
    end

    line_items = cart_products.map do |cp|
      {
        price_data: {
          currency: "eur",
          product_data: { name: cp.product.title },
          unit_amount: (cp.unit_price.to_f * 100).to_i
        },
        quantity: cp.quantity
      }
    end

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: line_items,
      mode: "payment",
      client_reference_id: order.id,
      # Utilise le placeholder Stripe non encodé pour que l'ID soit substitué
      success_url: "#{checkout_success_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: root_url + "?canceled=true"
    )

    redirect_to session.url, allow_other_host: true
  end

  def success
    session_id = params[:session_id]
    unless session_id
      redirect_to root_path, alert: "Session de paiement manquante." and return
    end

    session = Stripe::Checkout::Session.retrieve(session_id)
    unless session.payment_status == "paid"
      redirect_to root_path, alert: "Paiement non confirmé." and return
    end

    order = current_user.orders.find_by(id: session.client_reference_id)
    if order
      order.update(status: "paid")
      current_user.cart.cart_products.destroy_all
    end

    redirect_to user_path(current_user), notice: "Paiement confirmé, panier vidé."
  end
end
