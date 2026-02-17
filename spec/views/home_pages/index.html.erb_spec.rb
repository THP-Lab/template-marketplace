require 'rails_helper'

RSpec.describe "home_pages/index", type: :view do
  before(:each) do
    assign(:home_pages, [
      HomePage.create!(
        title: "Title",
        content: "MyText",
        position: 2
      ),
      HomePage.create!(
        title: "Title",
        content: "MyText",
        position: 2
      )
    ])
  end

  it "renders a list of home_pages" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Title".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
  end
end
