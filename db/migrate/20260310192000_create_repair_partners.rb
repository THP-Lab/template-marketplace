class CreateRepairPartners < ActiveRecord::Migration[8.1]
  def change
    create_table :repair_partners do |t|
      t.string :title, null: false
      t.string :url, null: false
      t.integer :position

      t.timestamps
    end

    add_index :repair_partners, :position
  end
end
