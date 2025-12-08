require 'rails_helper'

RSpec.describe "terms_pages/edit", type: :view do
  let(:terms_page) {
    TermsPage.create!(
      title: "MyString",
      content: "MyText",
      position: 1
    )
  }

  before(:each) do
    assign(:terms_page, terms_page)
  end

  it "renders the edit terms_page form" do
    render

    assert_select "form[action=?][method=?]", terms_page_path(terms_page), "post" do

      assert_select "input[name=?]", "terms_page[title]"

      assert_select "textarea[name=?]", "terms_page[content]"

      assert_select "input[name=?]", "terms_page[position]"
    end
  end
end
