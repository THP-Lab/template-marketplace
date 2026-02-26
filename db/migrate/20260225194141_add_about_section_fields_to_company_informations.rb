class AddAboutSectionFieldsToCompanyInformations < ActiveRecord::Migration[8.1]
  def change
    add_column :company_informations, :about_principal_title, :string
    add_column :company_informations, :about_principal_description, :text
    add_column :company_informations, :about_pontius_title, :string
    add_column :company_informations, :about_pontius_description, :text
    add_column :company_informations, :about_mon_parcours_title, :string
    add_column :company_informations, :about_mon_parcours_description, :text
  end
end
