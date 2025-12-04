require 'rails_helper'

RSpec.describe "about_sections/edit", type: :view do
  let(:about_section) {
    AboutSection.create!(
      title: "MyString",
      content: "MyText",
      position: 1
    )
  }

  before(:each) do
    assign(:about_section, about_section)
  end

  it "renders the edit about_section form" do
    render

    assert_select "form[action=?][method=?]", about_section_path(about_section), "post" do

      assert_select "input[name=?]", "about_section[title]"

      assert_select "textarea[name=?]", "about_section[content]"

      assert_select "input[name=?]", "about_section[position]"
    end
  end
end
