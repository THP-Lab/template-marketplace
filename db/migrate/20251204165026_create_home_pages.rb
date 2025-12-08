class CreateHomePages < ActiveRecord::Migration[8.1]
  def change
    create_table :home_pages do |t|
      t.string :title
      t.text :content
      t.integer :position

      t.timestamps
    end
  end
end
