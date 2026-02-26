class AddHomeBannerFieldsToCompanyInformations < ActiveRecord::Migration[8.1]
  def change
    add_column :company_informations, :home_banner_title, :string
    add_column :company_informations, :home_banner_subtitle, :string
    add_column :company_informations, :home_banner_primary_cta_label, :string
    add_column :company_informations, :home_banner_secondary_cta_label, :string
  end
end
