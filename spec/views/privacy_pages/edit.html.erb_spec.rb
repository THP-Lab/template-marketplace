require 'rails_helper'

RSpec.describe "privacy_pages/edit", type: :view do
  let(:privacy_page) {
    PrivacyPage.create!(
      title: "MyString",
      content: "MyText",
      position: 1
    )
  }

  before(:each) do
    assign(:privacy_page, privacy_page)
  end

  it "renders the edit privacy_page form" do
    render

    assert_select "form[action=?][method=?]", privacy_page_path(privacy_page), "post" do

      assert_select "input[name=?]", "privacy_page[title]"

      assert_select "textarea[name=?]", "privacy_page[content]"

      assert_select "input[name=?]", "privacy_page[position]"
    end
  end
end
