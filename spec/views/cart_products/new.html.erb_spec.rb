require 'rails_helper'

RSpec.describe "cart_products/new", type: :view do
  before(:each) do
    assign(:cart_product, CartProduct.new(
      cart: nil,
      product: nil,
      quantity: 1,
      unit_price: "9.99"
    ))
  end

  it "renders new cart_product form" do
    render

    assert_select "form[action=?][method=?]", cart_products_path, "post" do

      assert_select "input[name=?]", "cart_product[cart_id]"

      assert_select "input[name=?]", "cart_product[product_id]"

      assert_select "input[name=?]", "cart_product[quantity]"

      assert_select "input[name=?]", "cart_product[unit_price]"
    end
  end
end
