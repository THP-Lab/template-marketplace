require 'rails_helper'

RSpec.describe "repair_sections/edit", type: :view do
  let(:repair_section) {
    RepairSection.create!(
      title: "MyString",
      content: "MyText",
      position: 1
    )
  }

  before(:each) do
    assign(:repair_section, repair_section)
  end

  it "renders the edit repair_section form" do
    render

    assert_select "form[action=?][method=?]", repair_section_path(repair_section), "post" do

      assert_select "input[name=?]", "repair_section[title]"

      assert_select "textarea[name=?]", "repair_section[content]"

      assert_select "input[name=?]", "repair_section[position]"
    end
  end
end
