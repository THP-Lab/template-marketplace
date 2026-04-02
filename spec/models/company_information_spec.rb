require "rails_helper"

RSpec.describe CompanyInformation, type: :model do
  it "returns the shipping price for the first matching weight tier" do
    company_information = CompanyInformation.instance
    company_information.shipping_rates.create!(destination_zone: "france", max_weight: 1.0, price: 4.5)
    company_information.shipping_rates.create!(destination_zone: "france", max_weight: 3.0, price: 7.9)

    expect(company_information.shipping_amount_for(0.8)).to eq(4.5.to_d)
    expect(company_information.shipping_amount_for(2.2)).to eq(7.9.to_d)
  end

  it "falls back to the highest shipping tier when the total weight exceeds all thresholds" do
    company_information = CompanyInformation.instance
    company_information.shipping_rates.create!(destination_zone: "france", max_weight: 2.0, price: 6.0)
    company_information.shipping_rates.create!(destination_zone: "france", max_weight: 5.0, price: 9.5)

    expect(company_information.shipping_amount_for(9.2)).to eq(9.5.to_d)
  end

  it "uses international tiers for non-French countries" do
    company_information = CompanyInformation.instance
    company_information.shipping_rates.create!(destination_zone: "france", max_weight: 3.0, price: 7.9)
    company_information.shipping_rates.create!(destination_zone: "international", max_weight: 3.0, price: 16.5)

    expect(company_information.shipping_amount_for(2.2, destination_country: "Belgique")).to eq(16.5.to_d)
  end

  it "falls back to France tiers when no international tier is configured" do
    company_information = CompanyInformation.instance
    company_information.shipping_rates.create!(destination_zone: "france", max_weight: 3.0, price: 7.9)

    expect(company_information.shipping_amount_for(2.2, destination_country: "Canada")).to eq(7.9.to_d)
  end

  it "exposes a zero vat rate by default" do
    expect(CompanyInformation.instance.vat_rate_value).to eq(0.to_d)
  end
end
