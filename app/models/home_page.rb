class HomePage < ApplicationRecord
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

  def target_record
    case bloc_type
    when "about" then AboutPage.find_by(id: target_id)
    when "repair" then RepairPage.find_by(id: target_id)
    else nil
    end
  end

  def shop_products(limit = 5)
    case shop_scope
    when "last"
      Product.order(created_at: :desc).limit(limit)
    when "top_sellers"
      Product.left_joins(:order_products)
             .select("products.*, COALESCE(SUM(order_products.quantity), 0) AS total_sold")
             .group("products.id")
             .order(Arel.sql("total_sold DESC"))
             .limit(limit)
    else
      Product.order(created_at: :asc).limit(limit)
    end
  end
end
