require 'rails_helper'

RSpec.describe "repair_pages/edit", type: :view do
  let(:repair_page) {
    RepairPage.create!(
      title: "MyString",
      content: "MyText",
      position: 1
    )
  }

  before(:each) do
    assign(:repair_page, repair_page)
  end

  it "renders the edit repair_page form" do
    render

    assert_select "form[action=?][method=?]", repair_page_path(repair_page), "post" do

      assert_select "input[name=?]", "repair_page[title]"

      assert_select "textarea[name=?]", "repair_page[content]"

      assert_select "input[name=?]", "repair_page[position]"
    end
  end
end
