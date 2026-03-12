class AddShopProductsLimitToHomePages < ActiveRecord::Migration[8.1]
  def change
    add_column :home_pages, :shop_products_limit, :integer, default: 5, null: false
  end
end
