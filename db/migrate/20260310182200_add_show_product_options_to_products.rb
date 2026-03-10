class AddShowProductOptionsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :show_product_options, :boolean, null: false, default: false
  end
end
