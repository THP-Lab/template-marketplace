require "rails_helper"

RSpec.describe Product, type: :model do
  def attach_fake_image(record, name:, to_many: false)
    file = { io: StringIO.new("fake-image-content"), filename: "#{name}.png", content_type: "image/png" }
    to_many ? record.images.attach(file) : record.image.attach(file)
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
end
