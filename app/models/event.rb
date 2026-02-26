class Event < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validate :end_date_not_before_event_date

  # Utilisé par simple_calendar
  def start_time
    event_date || end_date
  end

  def end_time
    end_date || event_date
  end

  private

  def end_date_not_before_event_date
    return if event_date.blank? || end_date.blank?
    return unless end_date < event_date

    errors.add(:end_date, "doit être postérieure à la date de début")
  end
end
