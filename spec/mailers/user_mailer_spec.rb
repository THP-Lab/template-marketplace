require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:user) do
    User.create!(
      email: "mailer-spec@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      cgu_accepted: true,
      first_name: "Alice",
      last_name: "Martin",
      address: "12 Rue des Tests",
      zipcode: "75001",
      city: "Paris",
      country: "France",
      phone: "0607080910"
    )
  end

  let(:admin_user) do
    User.create!(
      email: "admin-mailer@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      cgu_accepted: true,
      is_admin: true,
      first_name: "Admin",
      last_name: "Spec",
      address: "1 Rue Admin",
      zipcode: "75010",
      city: "Paris",
      country: "France",
      phone: "0102030405"
    )
  end

  let(:order) do
    user.orders.create!(
      order_date: Time.current,
      status: "paid",
      items_amount: 40,
      shipping_amount: 8,
      tax_rate: 20,
      tax_amount: 9.6,
      total_amount: 57.6,
      shipping_weight: 2.4
    )
  end

  before do
    UserMailer.default from: "no-reply@example.com"
    admin_user
  end

  it "includes shipping and vat breakdown in the customer confirmation email" do
    mail = UserMailer.order_email(order)

    expect(mail.body.encoded).to include("Frais de port HT")
    expect(mail.body.encoded).to include("TVA (20%)")
    expect(mail.body.encoded).to include("Total TTC")
  end

  it "includes shipping and vat breakdown in the admin email" do
    mail = UserMailer.admin_order_email(order)

    expect(mail.body.encoded).to include("Frais de port HT")
    expect(mail.body.encoded).to include("TVA (20%)")
    expect(mail.body.encoded).to include("Total TTC")
  end
end
