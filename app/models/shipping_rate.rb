class ShippingRate < ApplicationRecord
  belongs_to :company_information

  validates :max_weight, numericality: { greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :max_weight, uniqueness: { scope: :company_information_id }

  scope :ordered, -> { order(:max_weight, :id) }
end
