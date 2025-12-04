require 'rails_helper'

RSpec.describe "repair_sections/new", type: :view do
  before(:each) do
    assign(:repair_section, RepairSection.new(
      title: "MyString",
      content: "MyText",
      position: 1
    ))
  end

  it "renders new repair_section form" do
    render

    assert_select "form[action=?][method=?]", repair_sections_path, "post" do

      assert_select "input[name=?]", "repair_section[title]"

      assert_select "textarea[name=?]", "repair_section[content]"

      assert_select "input[name=?]", "repair_section[position]"
    end
  end
end
