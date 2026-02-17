require 'rails_helper'

RSpec.describe "home_pages/edit", type: :view do
  let(:home_page) {
    HomePage.create!(
      title: "MyString",
      content: "MyText",
      position: 1
    )
  }

  before(:each) do
    assign(:home_page, home_page)
  end

  it "renders the edit home_page form" do
    render

    assert_select "form[action=?][method=?]", home_page_path(home_page), "post" do

      assert_select "input[name=?]", "home_page[title]"

      assert_select "textarea[name=?]", "home_page[content]"

      assert_select "input[name=?]", "home_page[position]"
    end
  end
end
