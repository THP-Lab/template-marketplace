require "rails_helper"

RSpec.describe Product, type: :model do
  def attach_fake_image(record, name:, to_many: false)
    file = { io: StringIO.new("fake-image-content"), filename: "#{name}.png", content_type: "image/png" }
    to_many ? record.images.attach(file) : record.image.attach(file)
  end

  def attach_fake_pdf(record, name: "document")
    record.file.attach(
      io: StringIO.new("%PDF-1.4 fake content"),
      filename: "#{name}.pdf",
      content_type: "application/pdf"
    )
  end

  it "builds a gallery with legacy image + multiple images and exposes a primary image" do
    product = Product.create!(title: "Casque", price: 99.0, stock: 2)
    attach_fake_image(product, name: "legacy", to_many: false)
    attach_fake_image(product, name: "gallery-1", to_many: true)
    attach_fake_image(product, name: "gallery-2", to_many: true)
    product.reload

    expect(product.gallery_images.size).to eq(3)
    expect(product.primary_image).to be_present
    expect(product.primary_image.id).to eq(product.gallery_images.first.id)
  end

  it "requires a selected document when the highlight document option is enabled" do
    product = Product.new(
      title: "Bouclier",
      price: 149.0,
      stock: 3,
      highlight_1_enabled: true,
      highlight_1_document_enabled: true
    )

    expect(product).not_to be_valid
    expect(product.errors[:highlight_1_company_document_id]).to include("doit être sélectionné")
  end

  it "exposes the selected document in highlight boxes" do
    company_information = CompanyInformation.instance
    document = company_information.company_documents.new(title: "Guide entretien")
    attach_fake_pdf(document, name: "guide-entretien")
    document.save!
    product = Product.create!(
      title: "Gantelet",
      price: 89.0,
      stock: 4,
      highlight_1_enabled: true,
      highlight_1_document_enabled: true,
      highlight_1_company_document: document
    )

    box = product.highlight_boxes.first
    expect(box[:document]).to eq(document)
  end
end
