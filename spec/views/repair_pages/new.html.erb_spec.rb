require 'rails_helper'

RSpec.describe "repair_pages/new", type: :view do
  before(:each) do
    assign(:repair_page, RepairPage.new(
      title: "MyString",
      content: "MyText",
      position: 1
    ))
  end

  it "renders new repair_page form" do
    render

    assert_select "form[action=?][method=?]", repair_pages_path, "post" do

      assert_select "input[name=?]", "repair_page[title]"

      assert_select "textarea[name=?]", "repair_page[content]"

      assert_select "input[name=?]", "repair_page[position]"
    end
  end
end
