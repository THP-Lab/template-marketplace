require "rails_helper"

RSpec.describe "Checkout", type: :request do
  let(:password) { "Password123!" }

  let!(:admin) do
    User.create!(
      email: "admin@example.com",
      password: password,
      password_confirmation: password,
      cgu_accepted: true,
      is_admin: true,
      first_name: "Admin",
      last_name: "User",
      address: "1 Rue Test",
      zipcode: "75001",
      city: "Paris",
      country: "France",
      phone: "0102030405"
    )
  end

  let!(:user) do
    User.create!(
      email: "client@example.com",
      password: password,
      password_confirmation: password,
      cgu_accepted: true,
      first_name: "Alice",
      last_name: "Client",
      address: "2 Rue Checkout",
      zipcode: "75002",
      city: "Paris",
      country: "France",
      phone: "0607080910"
    )
  end

  let!(:product) do
    Product.create!(
      title: "Cape",
      price: 29.99,
      stock: 5
    )
  end

  before do
    UserMailer.default from: "no-reply@example.com"
    admin
    post user_session_path, params: { user: { email: user.email, password: password } }
    user.cart.cart_products.create!(product: product, quantity: 2, unit_price: product.price)
  end

  it "creates the order only after a paid Stripe session" do
    allow(Stripe::Checkout::Session).to receive(:create).and_return(
      double("StripeCheckoutSession", id: "cs_test_123", url: "https://stripe.example/checkout")
    )

    expect {
      post checkout_path
    }.not_to change(Order, :count)

    expect(response).to redirect_to("https://stripe.example/checkout")

    allow(Stripe::Checkout::Session).to receive(:retrieve).with("cs_test_123").and_return(
      double("StripeCheckoutPaidSession", payment_status: "paid", client_reference_id: user.id.to_s)
    )

    expect {
      get checkout_success_path(session_id: "cs_test_123")
    }.to change(Order, :count).by(1)

    order = Order.last
    expect(order.user).to eq(user)
    expect(order.status).to eq("paid")
    expect(order.order_products.count).to eq(1)
    expect(order.order_products.first.product).to eq(product)
    expect(order.order_products.first.quantity).to eq(2)
    expect(user.cart.cart_products.reload).to be_empty
  end

  it "does not create a second order when success is called twice for the same Stripe session" do
    allow(Stripe::Checkout::Session).to receive(:create).and_return(
      double("StripeCheckoutSession", id: "cs_test_456", url: "https://stripe.example/checkout")
    )
    allow(Stripe::Checkout::Session).to receive(:retrieve).with("cs_test_456").and_return(
      double("StripeCheckoutPaidSession", payment_status: "paid", client_reference_id: user.id.to_s)
    )

    post checkout_path

    expect {
      get checkout_success_path(session_id: "cs_test_456")
    }.to change(Order, :count).by(1)

    expect {
      get checkout_success_path(session_id: "cs_test_456")
    }.not_to change(Order, :count)
  end
end
