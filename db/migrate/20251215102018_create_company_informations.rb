class CreateCompanyInformations < ActiveRecord::Migration[8.1]
  def change
    create_table :company_informations do |t|
      t.string :legal_name
      t.string :address_line1
      t.string :address_line2
      t.string :zipcode
      t.string :city
      t.string :country
      t.string :siret
      t.string :vat_number
      t.string :phone
      t.string :email
      t.text :additional_info

      t.timestamps
    end
  end
end
