class CreateShippingRates < ActiveRecord::Migration[8.1]
  def change
    create_table :shipping_rates do |t|
      t.references :company_information, null: false, foreign_key: true
      t.decimal :max_weight, precision: 10, scale: 3, null: false
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0

      t.timestamps
    end

    add_index :shipping_rates, [:company_information_id, :max_weight], unique: true
  end
end
