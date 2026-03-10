class AddSelectedOptionsToCartAndOrderProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :cart_products, :selected_options, :text, null: false, default: "[]"
    add_column :cart_products, :selected_options_signature, :string, null: false, default: "base"
    add_index :cart_products, [:cart_id, :product_id, :selected_options_signature], unique: true, name: "index_cart_products_on_cart_product_variant"

    add_column :order_products, :selected_options, :text, null: false, default: "[]"
    add_column :order_products, :selected_options_signature, :string, null: false, default: "base"
  end
end
