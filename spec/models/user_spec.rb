require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations Devise de base" do
    it "est valide avec un email et un mot de passe" do
      user = User.new(
        email: "test@example.com",
        password: "password123",
        password_confirmation: "password123"
      )

      expect(user).to be_valid
    end

    it "n'est pas valide sans email" do
      user = User.new(
        email: nil,
        password: "password123",
        password_confirmation: "password123"
      )

      expect(user).not_to be_valid
      expect(user.errors[:email]).not_to be_empty
    end

    it "n'est pas valide si les mots de passe ne correspondent pas" do
      user = User.new(
        email: "test@example.com",
        password: "password123",
        password_confirmation: "autrechose"
      )

      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).not_to be_empty
    end

    it "n'accepte pas deux users avec le même email" do
      User.create!(
        email: "test@example.com",
        password: "password123",
        password_confirmation: "password123"
      )

      user2 = User.new(
        email: "test@example.com",
        password: "password456",
        password_confirmation: "password456"
      )

      expect(user2).not_to be_valid
      expect(user2.errors[:email]).not_to be_empty
    end
  end

  describe "#valid_password?" do
    it "retourne true avec le bon mot de passe et false sinon" do
      user = User.create!(
        email: "test2@example.com",
        password: "password123",
        password_confirmation: "password123"
      )

      expect(user.valid_password?("password123")).to eq(true)
      expect(user.valid_password?("mauvaismdp")).to eq(false)
    end
  end
end
