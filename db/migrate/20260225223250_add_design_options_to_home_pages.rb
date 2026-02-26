class AddDesignOptionsToHomePages < ActiveRecord::Migration[8.1]
  class MigrationHomePage < ApplicationRecord
    self.table_name = "home_pages"
  end

  def up
    add_column :home_pages, :layout_variant, :string, null: false, default: "split"
    add_column :home_pages, :layout_background, :string, null: false, default: "theme"
    add_column :home_pages, :layout_text_tone, :string, null: false, default: "theme"
    add_column :home_pages, :layout_image_position, :string, null: false, default: "left"
    add_column :home_pages, :show_button, :boolean, null: false, default: true
    add_column :home_pages, :button_url, :string

    MigrationHomePage.reset_column_information
    MigrationHomePage.where(bloc_type: "custom").update_all(show_button: false)
  end

  def down
    remove_column :home_pages, :button_url
    remove_column :home_pages, :show_button
    remove_column :home_pages, :layout_image_position
    remove_column :home_pages, :layout_text_tone
    remove_column :home_pages, :layout_background
    remove_column :home_pages, :layout_variant
  end
end
