class RepairPage < ApplicationRecord
  include Positionable
  has_one_attached :image
end
