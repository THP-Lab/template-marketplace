class AddVatFieldsToCompanyInformationAndOrders < ActiveRecord::Migration[8.1]
  def up
    add_column :company_informations, :vat_rate, :decimal, precision: 5, scale: 2, default: 0, null: false
    add_column :orders, :tax_rate, :decimal, precision: 5, scale: 2, default: 0, null: false
    add_column :orders, :tax_amount, :decimal, precision: 10, scale: 2, default: 0, null: false
  end

  def down
    remove_column :orders, :tax_amount
    remove_column :orders, :tax_rate
    remove_column :company_informations, :vat_rate
  end
end
