require "rails_helper"

RSpec.describe "Events admin creation", type: :request do
  let(:password) { "123456" }
  let(:admin) do
    User.create!(
      email: "admin-events-#{SecureRandom.hex(4)}@example.com",
      password: password,
      password_confirmation: password,
      cgu_accepted: true,
      is_admin: true
    )
  end
  let(:other_user) do
    User.create!(
      email: "user-events-#{SecureRandom.hex(4)}@example.com",
      password: password,
      password_confirmation: password,
      cgu_accepted: true
    )
  end

  before do
    post user_session_path, params: { user: { email: admin.email, password: password } }
  end

  it "always links the created event to the connected admin" do
    expect do
      post events_path, params: {
        event: {
          user_id: other_user.id,
          title: "Marché de printemps",
          category: "Marché médiéval",
          description: "Animation sur le travail du métal",
          event_date: Time.zone.parse("2026-03-15 10:00"),
          end_date: Time.zone.parse("2026-03-15 18:00"),
          location: "Lyon"
        }
      }
    end.to change(Event, :count).by(1)

    created_event = Event.order(:id).last
    expect(created_event.user).to eq(admin)
  end
end
