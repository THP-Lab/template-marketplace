class AboutPage < ApplicationRecord
  include Positionable
  enum :section_type, {
    primary: "principal",
    secondary: "pontius",
    journey: "mon_parcours"
  }, suffix: true

  SECTION_LABELS = {
    "primary" => "Section principale",
    "secondary" => "Section secondaire",
    "journey" => "Mon parcours"
  }.freeze

  has_one_attached :image

  validates :section_type, presence: true

  def section_label
    SECTION_LABELS[section_type] || section_type.to_s.humanize
  end

  def self.section_options_for_select
    section_types.keys.map { |key| [SECTION_LABELS[key], key] }
  end

  def self.normalize_section_key(value)
    candidate = value.to_s
    return candidate if section_types.key?(candidate)

    {
      "principal" => "primary",
      "pontius" => "secondary",
      "mon_parcours" => "journey"
    }[candidate]
  end
end
