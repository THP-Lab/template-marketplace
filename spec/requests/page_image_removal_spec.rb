require "rails_helper"

RSpec.describe "Page image removal", type: :request do
  let(:admin) do
    User.create!(
      email: "admin-pages-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      cgu_accepted: true,
      is_admin: true
    )
  end

  before { sign_in admin, scope: :user }

  def attach_fake_image(record)
    record.image.attach(
      io: StringIO.new("fake-image-content"),
      filename: "test-image.png",
      content_type: "image/png"
    )
  end

  it "removes about page image when requested" do
    about_page = AboutPage.create!(
      title: "Section principale",
      content: "Contenu de test",
      section_type: "primary",
      position: 1
    )
    attach_fake_image(about_page)
    expect(about_page.image).to be_attached

    patch about_page_path(about_page), params: {
      about_page: {
        title: about_page.title,
        content: about_page.content,
        section_type: about_page.section_type,
        position: about_page.position,
        remove_image: "1"
      }
    }

    expect(response).to have_http_status(:see_other)
    about_page.reload
    expect(about_page.image).not_to be_attached
  end

  it "removes repair page image when requested" do
    repair_page = RepairPage.create!(
      title: "Réparation",
      content: "Bloc de test",
      position: 1
    )
    attach_fake_image(repair_page)
    expect(repair_page.image).to be_attached

    patch repair_page_path(repair_page), params: {
      repair_page: {
        title: repair_page.title,
        content: repair_page.content,
        position: repair_page.position,
        remove_image: "1"
      }
    }

    expect(response).to have_http_status(:see_other)
    repair_page.reload
    expect(repair_page.image).not_to be_attached
  end
end
