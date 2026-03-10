class CreateProductOptions < ActiveRecord::Migration[8.1]
  def change
    create_table :product_options do |t|
      t.references :product, null: false, foreign_key: true
      t.string :name, null: false
      t.string :option_kind, null: false, default: "custom"
      t.boolean :required, null: false, default: true

      t.timestamps
    end
  end
end
