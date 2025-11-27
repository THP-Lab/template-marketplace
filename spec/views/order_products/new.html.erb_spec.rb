require 'rails_helper'

RSpec.describe "order_products/new", type: :view do
  before(:each) do
    assign(:order_product, OrderProduct.new(
      order: nil,
      product: nil,
      quantity: 1,
      unit_price: "9.99"
    ))
  end

  it "renders new order_product form" do
    render

    assert_select "form[action=?][method=?]", order_products_path, "post" do

      assert_select "input[name=?]", "order_product[order_id]"

      assert_select "input[name=?]", "order_product[product_id]"

      assert_select "input[name=?]", "order_product[quantity]"

      assert_select "input[name=?]", "order_product[unit_price]"
    end
  end
end
