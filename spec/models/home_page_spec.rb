require 'rails_helper'

RSpec.describe HomePage, type: :model do
  describe "validations" do
    it "requires a shop_products_limit greater than 0" do
      home_page = described_class.new(bloc_type: :shop, shop_products_limit: 0)

      expect(home_page).not_to be_valid
      expect(home_page.errors.details[:shop_products_limit]).to include(hash_including(error: :greater_than, value: 0))
    end
  end

  describe "#shop_products" do
    let!(:product_1) { Product.create!(title: "Produit 1") }
    let!(:product_2) { Product.create!(title: "Produit 2") }
    let!(:product_3) { Product.create!(title: "Produit 3") }

    before do
      product_1.update_columns(created_at: Time.zone.local(2026, 1, 1, 9, 0, 0), updated_at: Time.zone.local(2026, 1, 1, 9, 0, 0))
      product_2.update_columns(created_at: Time.zone.local(2026, 1, 2, 9, 0, 0), updated_at: Time.zone.local(2026, 1, 2, 9, 0, 0))
      product_3.update_columns(created_at: Time.zone.local(2026, 1, 3, 9, 0, 0), updated_at: Time.zone.local(2026, 1, 3, 9, 0, 0))
    end

    it "uses shop_products_limit for first scope" do
      home_page = described_class.create!(bloc_type: :shop, shop_scope: :first, shop_products_limit: 2)

      expect(home_page.shop_products.pluck(:id)).to eq([product_1.id, product_2.id])
    end

    it "uses shop_products_limit for last scope" do
      home_page = described_class.create!(bloc_type: :shop, shop_scope: :last, shop_products_limit: 2)

      expect(home_page.shop_products.pluck(:id)).to eq([product_3.id, product_2.id])
    end

    it "falls back to at least 1 product when an invalid limit is passed" do
      home_page = described_class.create!(bloc_type: :shop, shop_scope: :first, shop_products_limit: 3)

      expect(home_page.shop_products(0).size).to eq(1)
    end
  end
end
