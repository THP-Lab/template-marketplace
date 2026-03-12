class HomePage < ApplicationRecord
  include Positionable
  before_validation :apply_bloc_type_rules

  enum :bloc_type, {
    custom: "custom",
    about: "about",
    repair: "repair",
    shop: "shop"
  }, suffix: true

  enum :shop_scope, {
    first: "first",
    last: "last",
    top_sellers: "top_sellers"
  }, suffix: true

  enum :layout_variant, {
    split: "split",
    cta_card: "cta_card"
  }, suffix: true

  enum :layout_background, {
    theme: "theme",
    white: "white"
  }, suffix: true

  enum :layout_text_tone, {
    theme: "theme",
    light: "light"
  }, suffix: true

  enum :layout_image_position, {
    left: "left",
    right: "right"
  }, suffix: true

  has_one_attached :image

  validates :button_url, length: { maximum: 1024 }, allow_blank: true
  validates :shop_products_limit,
            numericality: {
              only_integer: true,
              greater_than: 0,
              message: "doit être un entier supérieur à 0"
            }

  def target_record
    case bloc_type
    when "about" then AboutPage.find_by(id: target_id)
    when "repair" then RepairPage.find_by(id: target_id)
    else nil
    end
  end

  def shop_products(limit = shop_products_limit)
    safe_limit = [limit.to_i, 1].max

    case shop_scope
    when "last"
      Product.order(created_at: :desc).limit(safe_limit)
    when "top_sellers"
      Product.left_joins(:order_products)
             .select("products.*, COALESCE(SUM(order_products.quantity), 0) AS total_sold")
             .group("products.id")
             .order(Arel.sql("COALESCE(SUM(order_products.quantity), 0) DESC"))
             .limit(safe_limit)
    else
      Product.order(created_at: :asc).limit(safe_limit)
    end
  end

  def source_record
    return self if custom_bloc_type?

    target_record
  end

  def resolved_title
    title.presence || source_record&.title
  end

  def resolved_content
    content.presence || source_record&.content
  end

  def non_shop_block?
    !shop_bloc_type?
  end

  private

  def apply_bloc_type_rules
    case bloc_type
    when "custom"
      self.target_id = nil
      self.layout_variant = "split"
      self.show_button = false
      self.button_label = nil
      self.button_url = nil
    when "about", "repair"
      self.layout_variant = "cta_card"
      self.show_button = true
      self.button_url = nil
    when "shop"
      self.target_id = nil
      self.button_url = nil
    end
  end
end
