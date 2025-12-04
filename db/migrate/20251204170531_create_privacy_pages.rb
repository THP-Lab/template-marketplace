class CreatePrivacyPages < ActiveRecord::Migration[8.1]
  def change
    create_table :privacy_pages do |t|
      t.string :title
      t.text :content
      t.integer :position

      t.timestamps
    end
  end
end
