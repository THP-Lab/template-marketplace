require 'rails_helper'

RSpec.describe "privacy_pages/new", type: :view do
  before(:each) do
    assign(:privacy_page, PrivacyPage.new(
      title: "MyString",
      content: "MyText",
      position: 1
    ))
  end

  it "renders new privacy_page form" do
    render

    assert_select "form[action=?][method=?]", privacy_pages_path, "post" do

      assert_select "input[name=?]", "privacy_page[title]"

      assert_select "textarea[name=?]", "privacy_page[content]"

      assert_select "input[name=?]", "privacy_page[position]"
    end
  end
end
