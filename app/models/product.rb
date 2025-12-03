class Product < ApplicationRecord
  self.inheritance_column = :_type_disabled
  has_many :cart_products, dependent: :destroy
  has_many :carts, through: :cart_products

  scope :active, -> { where(deleted_at: nil) }
  
  # Méthode helper
  def deleted?
    deleted_at.present?
  end
end
