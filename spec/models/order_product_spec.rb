require "rails_helper"

RSpec.describe OrderProduct, type: :model do
  it "normalizes selected options signature before validation" do
    user = User.create!(email: "client-order@example.com", password: "password", cgu_accepted: true)
    order = user.orders.create!(status: "pending", order_date: Time.current, total_amount: 100)
    product = Product.create!(title: "Gants", price: 50, stock: 10)

    order_product = order.order_products.create!(
      product: product,
      quantity: 1,
      unit_price: 50,
      selected_options: [{ option_id: 3, value_id: 11 }, { option_id: 1, value_id: 2 }]
    )

    expect(order_product.selected_options_signature).to eq("1:2|3:11")
  end
end
