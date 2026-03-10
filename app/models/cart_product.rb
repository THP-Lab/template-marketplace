class CartProduct < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  serialize :selected_options, coder: JSON

  before_validation :normalize_selected_options

  validates :selected_options_signature, presence: true

  def self.signature_for(options)
    normalized = Array(options).map do |entry|
      hash = entry.is_a?(Hash) ? entry.with_indifferent_access : {}
      [hash[:option_id].to_i, hash[:value_id].to_i]
    end

    return "base" if normalized.empty?

    normalized.sort.map { |option_id, value_id| "#{option_id}:#{value_id}" }.join("|")
  end

  def selected_options_list
    Array(selected_options).map { |entry| entry.is_a?(Hash) ? entry.with_indifferent_access : {} }
  end

  def selected_options_label
    selected_options_list.map do |entry|
      option_name = entry[:option_name].presence || "Option"
      value_label = entry[:value_label].presence || "—"
      "#{option_name} : #{value_label}"
    end.join(" | ")
  end

  private

  def normalize_selected_options
    self.selected_options = selected_options_list
    self.selected_options_signature = self.class.signature_for(selected_options_list)
  end
end
