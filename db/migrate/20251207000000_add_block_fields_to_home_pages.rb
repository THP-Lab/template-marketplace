class AddBlockFieldsToHomePages < ActiveRecord::Migration[8.1]
  def change
    add_column :home_pages, :bloc_type, :string, default: "custom", null: false
    add_column :home_pages, :target_id, :integer
    add_column :home_pages, :shop_scope, :string, default: "first", null: false

    add_index :home_pages, :target_id
  end
end
