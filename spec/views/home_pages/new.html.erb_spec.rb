require 'rails_helper'

RSpec.describe "home_pages/new", type: :view do
  before(:each) do
    assign(:home_page, HomePage.new(
      title: "MyString",
      content: "MyText",
      position: 1
    ))
  end

  it "renders new home_page form" do
    render

    assert_select "form[action=?][method=?]", home_pages_path, "post" do

      assert_select "input[name=?]", "home_page[title]"

      assert_select "textarea[name=?]", "home_page[content]"

      assert_select "input[name=?]", "home_page[position]"
    end
  end
end
