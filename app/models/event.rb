class Event < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  has_many_attached :images

  validate :end_date_not_before_event_date

  # Utilisé par simple_calendar
  def start_time
    event_date || end_date
  end

  def end_time
    end_date || event_date
  end

  def gallery_images
    all_images = []
    all_images << image.attachment if image.attached?
    all_images.concat(images.attachments.to_a) if images.attached?
    all_images.uniq(&:id)
  end

  def primary_image
    gallery_images.first
  end

  private

  def end_date_not_before_event_date
    return if event_date.blank? || end_date.blank?
    return unless end_date < event_date

    errors.add(:end_date, "doit être postérieure à la date de début")
  end
end
