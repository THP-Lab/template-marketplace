class Order < ApplicationRecord
  belongs_to :user

  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products
  has_one :payment, dependent: :destroy

  after_create :order_send
  after_create :notify_admins

  def order_send
    UserMailer.order_email(self).deliver_now
  end

  def notify_admins
    UserMailer.admin_order_email(self).deliver_now
  end
end
