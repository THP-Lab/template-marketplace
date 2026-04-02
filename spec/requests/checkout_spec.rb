require "rails_helper"
require "ostruct"

RSpec.describe "Checkout", type: :request do
  let(:user) do
    User.create!(
      email: "checkout-spec@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      cgu_accepted: true,
      first_name: "Alice",
      last_name: "Martin",
      address: "12 Rue des Tests",
      zipcode: "75001",
      city: "Paris",
      country: "France",
      phone: "0607080910"
    )
  end

  let(:product) do
    Product.create!(
      title: "Casque lourd",
      price: 20,
      stock: 5,
      weight: 1.2
    )
  end

  let!(:admin_user) do
    User.create!(
      email: "admin-checkout@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      cgu_accepted: true,
      is_admin: true,
      first_name: "Admin",
      last_name: "Spec",
      address: "1 Rue Admin",
      zipcode: "75010",
      city: "Paris",
      country: "France",
      phone: "0102030405"
    )
  end

  before do
    UserMailer.default from: "no-reply@example.com"
    ActionMailer::Base.deliveries.clear
    sign_in user, scope: :user

    company_information = CompanyInformation.instance
    company_information.update!(vat_rate: 20, vat_number: "FR00123456789")
    company_information.shipping_rates.create!(destination_zone: "france", max_weight: 1.0, price: 5.0)
    company_information.shipping_rates.create!(destination_zone: "france", max_weight: 3.0, price: 8.0)

    user.cart.cart_products.create!(
      product: product,
      quantity: 2,
      unit_price: 20,
      unit_weight: 1.2,
      selected_options: [],
      selected_options_signature: "base"
    )
  end

  it "adds shipping as a dedicated Stripe line item based on total cart weight" do
    created_session = nil

    allow(Stripe::Checkout::Session).to receive(:create) do |payload|
      created_session = payload
      OpenStruct.new(id: "sess_weight_1", url: "https://stripe.test/checkout")
    end

    post checkout_path

    expect(response).to redirect_to("https://stripe.test/checkout")
    expect(created_session[:line_items].size).to eq(3)

    shipping_line = created_session[:line_items].find do |line|
      line.dig(:price_data, :product_data, :name) == "Frais de port"
    end
    expect(shipping_line[:quantity]).to eq(1)
    expect(shipping_line.dig(:price_data, :unit_amount)).to eq(800)

    vat_line = created_session[:line_items].find do |line|
      line.dig(:price_data, :product_data, :name) == "TVA (20.0%)"
    end
    expect(vat_line[:quantity]).to eq(1)
    expect(vat_line.dig(:price_data, :unit_amount)).to eq(960)
  end

  it "stores shipping totals on the paid order after Stripe success" do
    allow(Stripe::Checkout::Session).to receive(:create)
      .and_return(OpenStruct.new(id: "sess_weight_2", url: "https://stripe.test/checkout"))

    post checkout_path

    allow(Stripe::Checkout::Session).to receive(:retrieve)
      .with("sess_weight_2")
      .and_return(OpenStruct.new(payment_status: "paid", client_reference_id: user.id.to_s))

    expect {
      get checkout_success_path(session_id: "sess_weight_2")
    }.to change(Order, :count).by(1)
      .and change(OrderProduct, :count).by(1)

    order = user.orders.order(:id).last

    expect(order.items_amount_value).to eq(40.to_d)
    expect(order.shipping_amount_value).to eq(8.to_d)
    expect(order.tax_rate_value).to eq(20.to_d)
    expect(order.tax_amount_value).to eq(9.6.to_d)
    expect(order.shipping_weight_value).to eq(2.4.to_d)
    expect(order.total_amount_value).to eq(57.6.to_d)
    expect(order.order_products.first.unit_weight_value).to eq(1.2.to_d)
    expect(order.customer_email).to eq(user.email)
    expect(order.shipping_first_name).to eq(user.first_name)
    expect(order.shipping_last_name).to eq(user.last_name)
    expect(order.shipping_address).to eq(user.address)
    expect(order.shipping_zipcode).to eq(user.zipcode)
    expect(order.shipping_city).to eq(user.city)
    expect(order.shipping_country).to eq(user.country)
    expect(order.shipping_phone).to eq(user.phone)
    expect(user.cart.cart_products.reload).to be_empty
  end

  it "uses international shipping tiers when the user country is outside France" do
    company_information = CompanyInformation.instance
    company_information.shipping_rates.create!(destination_zone: "international", max_weight: 1.0, price: 12.0)
    company_information.shipping_rates.create!(destination_zone: "international", max_weight: 3.0, price: 18.0)
    user.update!(country: "Belgique")

    created_session = nil
    allow(Stripe::Checkout::Session).to receive(:create) do |payload|
      created_session = payload
      OpenStruct.new(id: "sess_weight_int_1", url: "https://stripe.test/checkout")
    end

    post checkout_path

    expect(response).to redirect_to("https://stripe.test/checkout")

    shipping_line = created_session[:line_items].find do |line|
      line.dig(:price_data, :product_data, :name) == "Frais de port"
    end

    expect(shipping_line).to be_present
    expect(shipping_line.dig(:price_data, :unit_amount)).to eq(1800)
  end
end
