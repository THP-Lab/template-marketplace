class Order < ApplicationRecord
  belongs_to :user

  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products
  has_one :payment, dependent: :destroy

  after_create :order_send

  def order_send
    UserMailer.order_email(self).deliver_now
  end
end
