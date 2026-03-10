class RepairPartner < ApplicationRecord
  include Positionable

  has_one_attached :logo

  validates :title, presence: true
  validates :url, presence: true
  validate :logo_presence
  validate :logo_must_be_an_image
  validate :url_format

  before_validation :normalize_url

  scope :ordered, -> { order(:position, :created_at) }

  private

  def normalize_url
    cleaned_url = url.to_s.strip
    self.url = cleaned_url
    return if cleaned_url.blank?
    return if cleaned_url.match?(%r{\Ahttps?://}i)

    self.url = "https://#{cleaned_url}"
  end

  def logo_presence
    errors.add(:logo, "doit être ajouté") unless logo.attached?
  end

  def logo_must_be_an_image
    return unless logo.attached?
    return if logo.blob.content_type.to_s.start_with?("image/")

    errors.add(:logo, "doit être une image")
  end

  def url_format
    return if url.blank?
    return if url.match?(%r{\Ahttps?://[^\s]+\z}i)

    errors.add(:url, "n'est pas valide")
  end
end
