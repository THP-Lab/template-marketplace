require 'rails_helper'

RSpec.describe "order_products/show", type: :view do
  before(:each) do
    assign(:order_product, OrderProduct.create!(
      order: nil,
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
