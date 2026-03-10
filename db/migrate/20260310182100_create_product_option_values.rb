class CreateProductOptionValues < ActiveRecord::Migration[8.1]
  def change
    create_table :product_option_values do |t|
      t.references :product_option, null: false, foreign_key: true
      t.string :label, null: false
      t.decimal :price_delta, precision: 10, scale: 2, null: false, default: 0
      t.string :hex_color

      t.timestamps
    end
  end
end
