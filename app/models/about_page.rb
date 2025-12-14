class AboutPage < ApplicationRecord
  include Positionable
  has_one_attached :image
end
