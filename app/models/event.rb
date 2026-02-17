class Event < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  # Utilisé par simple_calendar
  def start_time
    event_date
  end
end
