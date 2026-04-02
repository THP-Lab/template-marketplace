class ShippingRate < ApplicationRecord
  belongs_to :company_information

  enum :destination_zone, {
    france: "france",
    international: "international"
  }, suffix: true

  DESTINATION_ZONE_LABELS = {
    "france" => "France",
    "international" => "International"
  }.freeze

  validates :max_weight, numericality: { greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :destination_zone, presence: true, inclusion: { in: destination_zones.keys }
  validates :max_weight, uniqueness: { scope: [ :company_information_id, :destination_zone ] }

  scope :ordered, -> { order(:max_weight, :id) }
  scope :for_destination_zone, ->(zone) { where(destination_zone: zone) }

  def destination_zone_label
    DESTINATION_ZONE_LABELS[destination_zone] || destination_zone.to_s.humanize
  end
end
