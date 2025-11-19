class Product < ApplicationRecord
  has_many :cart_products
  has_many :order_products
  has_many :carts, through: :cart_products
  has_many :orders, through: :order_products

  
end
