require "rails_helper"

RSpec.describe Order, type: :model do
  let(:password) { "Password123!" }

  let!(:admin) do
    User.create!(
      email: "admin-order-spec@example.com",
      password: password,
      password_confirmation: password,
      cgu_accepted: true,
      is_admin: true,
      first_name: "Admin",
      last_name: "Spec",
      address: "1 Rue Test",
      zipcode: "75001",
      city: "Paris",
      country: "France",
      phone: "0102030405"
    )
  end

  let!(:user) do
    User.create!(
      email: "client-order-spec@example.com",
      password: password,
      password_confirmation: password,
      cgu_accepted: true,
      first_name: "Alice",
      last_name: "Spec",
      address: "2 Rue Test",
      zipcode: "75002",
      city: "Paris",
      country: "France",
      phone: "0607080910"
    )
  end

  before do
    UserMailer.default from: "no-reply@example.com"
    ActionMailer::Base.deliveries.clear
    admin
    user
    ActionMailer::Base.deliveries.clear
  end

  it "does not send order emails when a pending order is created" do
    expect {
      user.orders.create!(order_date: Time.current, status: "pending", total_amount: 10)
    }.not_to change(ActionMailer::Base.deliveries, :count)
  end

  it "sends order emails when a paid order is created" do
    expect {
      user.orders.create!(order_date: Time.current, status: "paid", total_amount: 10)
    }.to change(ActionMailer::Base.deliveries, :count).by(2)
  end
end
