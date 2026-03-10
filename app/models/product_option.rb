class ProductOption < ApplicationRecord
  OPTION_KIND_SIZE = "size".freeze
  OPTION_KIND_COLOR = "color".freeze
  OPTION_KIND_CUSTOM = "custom".freeze

  OPTION_KINDS = [OPTION_KIND_SIZE, OPTION_KIND_COLOR, OPTION_KIND_CUSTOM].freeze
  KIND_OPTIONS_FOR_SELECT = [
    ["Taille", OPTION_KIND_SIZE],
    ["Couleur", OPTION_KIND_COLOR],
    ["Personnalisé", OPTION_KIND_CUSTOM]
  ].freeze

  belongs_to :product
  has_many :product_option_values, -> { order(:id) }, dependent: :destroy, inverse_of: :product_option

  accepts_nested_attributes_for :product_option_values,
                                allow_destroy: true,
                                reject_if: proc { |attributes| attributes["label"].blank? && attributes["hex_color"].blank? && attributes["price_delta"].blank? }

  validates :name, presence: true
  validates :option_kind, inclusion: { in: OPTION_KINDS }
  validate :must_have_values_when_enabled

  before_validation :set_default_name_for_kind

  scope :ordered, -> { order(:id) }

  def color?
    option_kind == OPTION_KIND_COLOR
  end

  def size?
    option_kind == OPTION_KIND_SIZE
  end

  def custom?
    option_kind == OPTION_KIND_CUSTOM
  end

  def display_name
    name.presence || default_name_for_kind
  end

  def available_values
    product_option_values.reject(&:marked_for_destruction?)
  end

  private

  def set_default_name_for_kind
    self.name = default_name_for_kind if name.blank?
  end

  def default_name_for_kind
    case option_kind
    when OPTION_KIND_SIZE
      "Taille"
    when OPTION_KIND_COLOR
      "Couleur"
    else
      "Option"
    end
  end

  def must_have_values_when_enabled
    return if marked_for_destruction?
    return if available_values.any?

    errors.add(:base, "Ajoutez au moins un choix pour l'option #{display_name}")
  end
end
