class Product < ApplicationRecord
  self.inheritance_column = :_type_disabled
  has_many :cart_products, dependent: :destroy
  has_many :carts, through: :cart_products
  has_many :order_products, dependent: :restrict_with_error
  has_one_attached :image
end
