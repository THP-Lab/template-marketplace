require 'rails_helper'

RSpec.describe "about_sections/index", type: :view do
  before(:each) do
    assign(:about_sections, [
      AboutSection.create!(
        title: "Title",
        content: "MyText",
        position: 2
      ),
      AboutSection.create!(
        title: "Title",
        content: "MyText",
        position: 2
      )
    ])
  end

  it "renders a list of about_sections" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Title".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
  end
end
