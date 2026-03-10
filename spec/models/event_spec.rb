require 'rails_helper'

RSpec.describe Event, type: :model do
  def attach_fake_image(record, name:, to_many: false)
    file = { io: StringIO.new("fake-image-content"), filename: "#{name}.png", content_type: "image/png" }
    to_many ? record.images.attach(file) : record.image.attach(file)
  end

  let(:user) do
    User.create!(
      email: "event-admin-#{SecureRandom.hex(4)}@example.com",
      password: "123456",
      password_confirmation: "123456",
      cgu_accepted: true,
      is_admin: true
    )
  end

  it "is invalid when end_date is before event_date" do
    event = Event.new(
      user: user,
      title: "Atelier",
      event_date: Time.current,
      end_date: 1.hour.ago
    )

    expect(event).not_to be_valid
    expect(event.errors[:end_date]).to include("doit être postérieure à la date de début")
  end

  it "returns fallback start_time and end_time when only one date exists" do
    starts_only = Event.new(user: user, event_date: Time.current)
    ends_only = Event.new(user: user, end_date: 2.hours.from_now)

    expect(starts_only.start_time).to eq(starts_only.event_date)
    expect(starts_only.end_time).to eq(starts_only.event_date)
    expect(ends_only.start_time).to eq(ends_only.end_date)
    expect(ends_only.end_time).to eq(ends_only.end_date)
  end

  it "builds a gallery with legacy image + multiple images and exposes a primary image" do
    event = Event.create!(user: user, title: "Marché médiéval")
    attach_fake_image(event, name: "legacy", to_many: false)
    attach_fake_image(event, name: "gallery-1", to_many: true)
    attach_fake_image(event, name: "gallery-2", to_many: true)
    event.reload

    expect(event.gallery_images.size).to eq(3)
    expect(event.primary_image).to be_present
    expect(event.primary_image.id).to eq(event.gallery_images.first.id)
  end
end
