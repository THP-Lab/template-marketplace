require 'rails_helper'

RSpec.describe "about_sections/new", type: :view do
  before(:each) do
    assign(:about_section, AboutSection.new(
      title: "MyString",
      content: "MyText",
      position: 1
    ))
  end

  it "renders new about_section form" do
    render

    assert_select "form[action=?][method=?]", about_sections_path, "post" do

      assert_select "input[name=?]", "about_section[title]"

      assert_select "textarea[name=?]", "about_section[content]"

      assert_select "input[name=?]", "about_section[position]"
    end
  end
end
