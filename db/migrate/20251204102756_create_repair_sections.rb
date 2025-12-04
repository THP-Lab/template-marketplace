class CreateRepairSections < ActiveRecord::Migration[8.1]
  def change
    create_table :repair_sections do |t|
      t.string :title
      t.text :content
      t.integer :position

      t.timestamps
    end
  end
end
