require 'rails_helper'

RSpec.describe "cart_products/edit", type: :view do
  let(:cart_product) {
    CartProduct.create!(
      cart: nil,
      product: nil,
      quantity: 1,
      unit_price: "9.99"
    )
  }

  before(:each) do
    assign(:cart_product, cart_product)
  end

  it "renders the edit cart_product form" do
    render

    assert_select "form[action=?][method=?]", cart_product_path(cart_product), "post" do

      assert_select "input[name=?]", "cart_product[cart_id]"

      assert_select "input[name=?]", "cart_product[product_id]"

      assert_select "input[name=?]", "cart_product[quantity]"

      assert_select "input[name=?]", "cart_product[unit_price]"
    end
  end
end
