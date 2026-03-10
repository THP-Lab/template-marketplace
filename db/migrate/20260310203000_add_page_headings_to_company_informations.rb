class AddPageHeadingsToCompanyInformations < ActiveRecord::Migration[8.1]
  def change
    add_column :company_informations, :shop_page_title, :string, default: "", null: false
    add_column :company_informations, :shop_page_subtitle, :string, default: "", null: false
    add_column :company_informations, :events_page_title, :string, default: "", null: false
    add_column :company_informations, :events_page_subtitle, :string, default: "", null: false
    add_column :company_informations, :repair_page_title, :string, default: "", null: false
    add_column :company_informations, :repair_page_subtitle, :string, default: "", null: false
    add_column :company_informations, :contact_page_title, :string, default: "", null: false
    add_column :company_informations, :contact_page_subtitle, :string, default: "", null: false
  end
end
