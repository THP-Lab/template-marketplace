require 'rails_helper'

RSpec.describe "cart_products/show", type: :view do
  before(:each) do
    assign(:cart_product, CartProduct.create!(
      cart: nil,
      product: nil,
      quantity: 2,
      unit_price: "9.99"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/9.99/)
  end
end
