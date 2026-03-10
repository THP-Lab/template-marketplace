class AddRepairPartnersSectionTitleToCompanyInformations < ActiveRecord::Migration[8.1]
  def change
    add_column :company_informations, :repair_partners_section_title, :string, default: "", null: false
  end
end
