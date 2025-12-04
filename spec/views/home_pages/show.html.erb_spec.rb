require 'rails_helper'

RSpec.describe "home_pages/show", type: :view do
  before(:each) do
    assign(:home_page, HomePage.create!(
      title: "Title",
      content: "MyText",
      position: 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/2/)
  end
end
