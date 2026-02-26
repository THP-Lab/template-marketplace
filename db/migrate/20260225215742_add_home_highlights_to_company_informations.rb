class AddHomeHighlightsToCompanyInformations < ActiveRecord::Migration[8.1]
  def change
    add_column :company_informations, :home_highlight_1_title, :string
    add_column :company_informations, :home_highlight_1_description, :text
    add_column :company_informations, :home_highlight_2_title, :string
    add_column :company_informations, :home_highlight_2_description, :text
    add_column :company_informations, :home_highlight_3_title, :string
    add_column :company_informations, :home_highlight_3_description, :text
    add_column :company_informations, :home_highlight_4_title, :string
    add_column :company_informations, :home_highlight_4_description, :text
  end
end
