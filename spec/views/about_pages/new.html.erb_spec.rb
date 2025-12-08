require 'rails_helper'

RSpec.describe "about_pages/new", type: :view do
  before(:each) do
    assign(:about_page, AboutPage.new(
      title: "MyString",
      content: "MyText",
      position: 1
    ))
  end

  it "renders new about_page form" do
    render

    assert_select "form[action=?][method=?]", about_pages_path, "post" do

      assert_select "input[name=?]", "about_page[title]"

      assert_select "textarea[name=?]", "about_page[content]"

      assert_select "input[name=?]", "about_page[position]"
    end
  end
end
