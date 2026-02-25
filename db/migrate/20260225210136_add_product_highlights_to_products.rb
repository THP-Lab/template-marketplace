class AddProductHighlightsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :show_product_highlights, :boolean, default: true, null: false
    add_column :products, :highlight_1_title, :string
    add_column :products, :highlight_1_description, :text
    add_column :products, :highlight_2_title, :string
    add_column :products, :highlight_2_description, :text
    add_column :products, :highlight_3_title, :string
    add_column :products, :highlight_3_description, :text
  end
end
