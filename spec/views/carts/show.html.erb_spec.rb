require 'rails_helper'

RSpec.describe "carts/show", type: :view do
  before(:each) do
    assign(:cart, Cart.create!(
      user: nil,
      status: "Status"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Status/)
  end
end
