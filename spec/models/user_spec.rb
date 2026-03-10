require "rails_helper"

RSpec.describe User, type: :model do
  let(:base_attributes) do
    {
      email: "checkout-validation@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      cgu_accepted: true
    }
  end

  it "does not require checkout-only fields in default context" do
    user = User.new(base_attributes)

    expect(user).to be_valid
  end

  it "requires full profile fields in checkout context" do
    user = User.new(base_attributes)

    expect(user.valid?(:checkout)).to be(false)
    expect(user.errors[:first_name]).to be_present
    expect(user.errors[:address]).to be_present
    expect(user.errors[:zipcode]).to be_present
    expect(user.errors[:city]).to be_present
    expect(user.errors[:country]).to be_present
    expect(user.errors[:phone]).to be_present
  end

  it "accepts checkout context when all required fields are filled" do
    user = User.new(
      base_attributes.merge(
        first_name: "Alice",
        last_name: "Martin",
        address: "1 Rue du Temple",
        zipcode: "75001",
        city: "Paris",
        country: "France",
        phone: "0607080910"
      )
    )

    expect(user.valid?(:checkout)).to be(true)
  end
end
