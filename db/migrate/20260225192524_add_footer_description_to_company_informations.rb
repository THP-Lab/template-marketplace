class AddFooterDescriptionToCompanyInformations < ActiveRecord::Migration[8.1]
  def change
    add_column :company_informations, :footer_description, :text
  end
end
