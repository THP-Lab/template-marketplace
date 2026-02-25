class AddHighlightEnabledFlagsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :highlight_1_enabled, :boolean, default: true, null: false
    add_column :products, :highlight_2_enabled, :boolean, default: true, null: false
    add_column :products, :highlight_3_enabled, :boolean, default: true, null: false
  end
end
