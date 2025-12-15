class Order < ApplicationRecord
  STATUS_ORDER = %w[pending paid processing shipped delivered canceled].freeze
  STATUS_LABELS = {
    "pending" => "En attente",
    "paid" => "Payée",
    "processing" => "En préparation",
    "shipped" => "Expédiée",
    "delivered" => "Livrée",
    "canceled" => "Annulée",
    "cancelled" => "Annulée"
  }.freeze

  belongs_to :user

  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products
  has_one :payment, dependent: :destroy

  after_create :order_send
  after_create :notify_admins
  after_update_commit :notify_status_change, if: :notify_status_update?

  def order_send
    UserMailer.order_email(self).deliver_now
  end

  def notify_admins
    UserMailer.admin_order_email(self).deliver_now
  end

  def status_label(value = status)
    STATUS_LABELS[value.to_s] || value.to_s.humanize
  end

  def self.status_options_for_select
    STATUS_ORDER.map { |status| [STATUS_LABELS[status] || status.humanize, status] }
  end

  private

  def notify_status_change
    previous_status = status_before_last_save
    UserMailer.order_status_update_email(self, previous_status: previous_status).deliver_now
  end

  def notify_status_update?
    saved_change_to_status? || (status == "shipped" && saved_change_to_tracking_number?)
  end
end
