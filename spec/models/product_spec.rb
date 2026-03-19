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

  it "builds a selection snapshot for multiple options and computes price delta" do
    product = Product.create!(title: "Haubert", price: 120.0, stock: 2, weight: 1.25)
    size_option = product.product_options.create!(
      name: "Taille",
      option_kind: "size",
      product_option_values_attributes: [{ label: "56", price_delta: 15, weight_override: 1.8 }]
    )
    size_56 = size_option.product_option_values.first
    color_option = product.product_options.create!(
      name: "Couleur",
      option_kind: "color",
      product_option_values_attributes: [{ label: "Noir", hex_color: "#111111", price_delta: 5 }]
    )
    color_noir = color_option.product_option_values.first
    product.update!(show_product_options: true)

    snapshot, errors = product.build_option_selection_snapshot(
      size_option.id.to_s => size_56.id.to_s,
      color_option.id.to_s => color_noir.id.to_s
    )

    expect(errors).to be_empty
    expect(snapshot.size).to eq(2)
    expect(product.option_price_delta(snapshot)).to eq(20.to_d)
    expect(product.weight_for_selection(snapshot)).to eq(1.8.to_d)
  end

  it "returns an error when an option is missing in selected values" do
    product = Product.create!(title: "Brassard", price: 80.0, stock: 3)
    product.product_options.create!(
      name: "Taille",
      option_kind: "size",
      product_option_values_attributes: [{ label: "S", price_delta: 0 }]
    )
    product.update!(show_product_options: true)

    _snapshot, errors = product.build_option_selection_snapshot({})

    expect(errors).not_to be_empty
  end

  it "uses the heaviest selected variant weight instead of stacking with the base product weight" do
    product = Product.create!(title: "Tunique", price: 70.0, stock: 2, weight: 0.9)
    size_option = product.product_options.create!(
      name: "Taille",
      option_kind: "size",
      product_option_values_attributes: [{ label: "L", price_delta: 0, weight_override: 1.1 }]
    )
    finish_option = product.product_options.create!(
      name: "Finition",
      option_kind: "custom",
      product_option_values_attributes: [{ label: "Renforcée", price_delta: 12, weight_override: 1.7 }]
    )
    product.update!(show_product_options: true)

    snapshot, errors = product.build_option_selection_snapshot(
      size_option.id.to_s => size_option.product_option_values.first.id.to_s,
      finish_option.id.to_s => finish_option.product_option_values.first.id.to_s
    )

    expect(errors).to be_empty
    expect(product.weight_for_selection(snapshot)).to eq(1.7.to_d)
  end
end
