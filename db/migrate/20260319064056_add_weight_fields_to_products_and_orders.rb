class AddWeightFieldsToProductsAndOrders < ActiveRecord::Migration[8.1]
  def up
    add_column :products, :weight, :decimal, precision: 10, scale: 3
    add_column :product_option_values, :weight_override, :decimal, precision: 10, scale: 3
    add_column :cart_products, :unit_weight, :decimal, precision: 10, scale: 3
    add_column :order_products, :unit_weight, :decimal, precision: 10, scale: 3
    add_column :orders, :items_amount, :decimal, precision: 10, scale: 2
    add_column :orders, :shipping_amount, :decimal, precision: 10, scale: 2, default: 0, null: false
    add_column :orders, :shipping_weight, :decimal, precision: 10, scale: 3, default: 0, null: false

    execute <<~SQL.squish
      UPDATE orders
      SET items_amount = total_amount
      WHERE items_amount IS NULL
    SQL
  end

  def down
    remove_column :orders, :shipping_weight
    remove_column :orders, :shipping_amount
    remove_column :orders, :items_amount
    remove_column :order_products, :unit_weight
    remove_column :cart_products, :unit_weight
    remove_column :product_option_values, :weight_override
    remove_column :products, :weight
  end
end
