class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.datetime :event_date
      t.string :location
      t.string :image_url

      t.timestamps
    end
  end
end
