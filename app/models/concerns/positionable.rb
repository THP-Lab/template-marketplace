module Positionable
  extend ActiveSupport::Concern

  included do
    before_create :assign_last_position
  end

  private

  def assign_last_position
    return if position.present?

    self.position = self.class.maximum(:position).to_i + 1
  end
end
