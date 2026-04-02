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

  before_validation :assign_shipping_snapshot_from_user, on: :create
  after_create_commit :order_send, if: -> { status == "paid" }
  after_create_commit :notify_admins, if: -> { status == "paid" }
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
    STATUS_ORDER.map { |status| [ STATUS_LABELS[status] || status.humanize, status ] }
  end

  def items_amount_value
    return items_amount.to_d if items_amount.present?

    order_products.sum(&:line_total)
  end

  def shipping_amount_value
    shipping_amount.to_d
  end

  def shipping_weight_value
    return shipping_weight.to_d if shipping_weight.present?

    order_products.sum(&:line_weight)
  end

  def tax_rate_value
    tax_rate.to_d
  end

  def tax_amount_value
    tax_amount.to_d
  end

  def total_amount_value
    return total_amount.to_d if total_amount.present?

    items_amount_value + shipping_amount_value + tax_amount_value
  end

  def shipping_snapshot
    {
      email: customer_email.presence || user&.email,
      first_name: shipping_first_name.presence || user&.first_name,
      last_name: shipping_last_name.presence || user&.last_name,
      address: shipping_address.presence || user&.address,
      zipcode: shipping_zipcode.presence || user&.zipcode,
      city: shipping_city.presence || user&.city,
      country: shipping_country.presence || user&.country,
      phone: shipping_phone.presence || user&.phone
    }
  end

  def shipping_recipient_name
    [ shipping_snapshot[:first_name], shipping_snapshot[:last_name] ].map(&:presence).compact.join(" ").presence
  end

  def shipping_location_line
    [ shipping_snapshot[:zipcode], shipping_snapshot[:city], shipping_snapshot[:country] ].map(&:presence).compact.join(" ").presence
  end

  private

  def assign_shipping_snapshot_from_user
    return unless user.present?

    self.customer_email = user.email if customer_email.blank?
    self.shipping_first_name = user.first_name if shipping_first_name.blank?
    self.shipping_last_name = user.last_name if shipping_last_name.blank?
    self.shipping_address = user.address if shipping_address.blank?
    self.shipping_zipcode = user.zipcode if shipping_zipcode.blank?
    self.shipping_city = user.city if shipping_city.blank?
    self.shipping_country = user.country if shipping_country.blank?
    self.shipping_phone = user.phone if shipping_phone.blank?
  end

  def notify_status_change
    previous_status = status_before_last_save
    UserMailer.order_status_update_email(self, previous_status: previous_status).deliver_now
  end

  def notify_status_update?
    saved_change_to_status? || (status == "shipped" && saved_change_to_tracking_number?)
  end
end
