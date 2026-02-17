class Product < ApplicationRecord
  self.inheritance_column = :_type_disabled
  has_many :cart_products
  has_many :carts, through: :cart_products
  has_many :order_products
  has_one_attached :image
end
