require 'rails_helper'

RSpec.describe "about_pages/edit", type: :view do
  let(:about_page) {
    AboutPage.create!(
      title: "MyString",
      content: "MyText",
      position: 1
    )
  }

  before(:each) do
    assign(:about_page, about_page)
  end

  it "renders the edit about_page form" do
    render

    assert_select "form[action=?][method=?]", about_page_path(about_page), "post" do

      assert_select "input[name=?]", "about_page[title]"

      assert_select "textarea[name=?]", "about_page[content]"

      assert_select "input[name=?]", "about_page[position]"
    end
  end
end
