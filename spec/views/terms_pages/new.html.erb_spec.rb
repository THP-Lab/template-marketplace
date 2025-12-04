require 'rails_helper'

RSpec.describe "terms_pages/new", type: :view do
  before(:each) do
    assign(:terms_page, TermsPage.new(
      title: "MyString",
      content: "MyText",
      position: 1
    ))
  end

  it "renders new terms_page form" do
    render

    assert_select "form[action=?][method=?]", terms_pages_path, "post" do

      assert_select "input[name=?]", "terms_page[title]"

      assert_select "textarea[name=?]", "terms_page[content]"

      assert_select "input[name=?]", "terms_page[position]"
    end
  end
end
