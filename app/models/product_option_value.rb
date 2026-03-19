class ProductOptionValue < ApplicationRecord
  HEX_COLOR_FORMAT = /\A#(?:\h{3}|\h{6})\z/.freeze

  belongs_to :product_option, inverse_of: :product_option_values

  validates :label, presence: true
  validates :price_delta, numericality: true
  validates :weight_override, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :hex_color, format: { with: HEX_COLOR_FORMAT, message: "doit être un code HEX valide (#RRGGBB)" }, allow_blank: true
  validate :hex_color_required_for_color_option

  before_validation :normalize_hex_color

  scope :ordered, -> { order(:id) }

  def selection_payload
    {
      option_id: product_option_id,
      option_name: product_option.display_name,
      option_kind: product_option.option_kind,
      value_id: id,
      value_label: label,
      hex_color: hex_color.presence,
      price_delta: price_delta.to_d.to_s("F"),
      weight_override: weight_override.presence&.to_d&.to_s("F")
    }
  end

  private

  def normalize_hex_color
    return if hex_color.blank?

    normalized = hex_color.to_s.strip
    normalized = "##{normalized}" unless normalized.start_with?("#")
    self.hex_color = normalized.upcase
  end

  def hex_color_required_for_color_option
    return unless product_option&.color?
    return if marked_for_destruction?
    return if hex_color.present?

    errors.add(:hex_color, "est obligatoire pour une option couleur")
  end
end
