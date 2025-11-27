require 'rails_helper'

RSpec.describe "order_products/edit", type: :view do
  let(:order_product) {
    OrderProduct.create!(
      order: nil,
      product: nil,
      quantity: 1,
      unit_price: "9.99"
    )
  }

  before(:each) do
    assign(:order_product, order_product)
  end

  it "renders the edit order_product form" do
    render

    assert_select "form[action=?][method=?]", order_product_path(order_product), "post" do

      assert_select "input[name=?]", "order_product[order_id]"

      assert_select "input[name=?]", "order_product[product_id]"

      assert_select "input[name=?]", "order_product[quantity]"

      assert_select "input[name=?]", "order_product[unit_price]"
    end
  end
end
