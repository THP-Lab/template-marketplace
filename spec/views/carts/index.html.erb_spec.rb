require 'rails_helper'

RSpec.describe "carts/index", type: :view do
  before(:each) do
    assign(:carts, [
      Cart.create!(
        user: nil,
        status: "Status"
      ),
      Cart.create!(
        user: nil,
        status: "Status"
      )
    ])
  end

  it "renders a list of carts" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Status".to_s), count: 2
  end
end
