class AddDestinationZoneToShippingRates < ActiveRecord::Migration[8.1]
  def change
    add_column :shipping_rates, :destination_zone, :string, null: false, default: "france"

    remove_index :shipping_rates, name: "index_shipping_rates_on_company_information_id_and_max_weight"

    add_index :shipping_rates,
              [ :company_information_id, :destination_zone, :max_weight ],
              unique: true,
              name: "index_shipping_rates_on_company_info_zone_and_max_weight"
  end
end
