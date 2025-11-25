class CheckoutController < ApplicationController
  def create
    cart = current_user.cart
    cart_products = cart.cart_products.includes(:product)

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
      payment_method_types: ["card"],
      line_items: line_items,
      mode: "payment",
      success_url: root_url + "?success=true",
      cancel_url: root_url + "?canceled=true"
    )

    redirect_to session.url, allow_other_host: true

  end
end
