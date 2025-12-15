class CreatePageMetas < ActiveRecord::Migration[7.1]
  def change
    create_table :page_metas do |t|
      t.string :page_key, null: false
      t.string :meta_title
      t.text :meta_description

      t.timestamps
    end

    add_index :page_metas, :page_key, unique: true
  end
end
