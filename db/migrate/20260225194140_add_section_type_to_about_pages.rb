class AddSectionTypeToAboutPages < ActiveRecord::Migration[8.1]
  def change
    add_column :about_pages, :section_type, :string, default: "mon_parcours"
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE about_pages
          SET section_type = 'mon_parcours'
          WHERE section_type IS NULL OR section_type = ''
        SQL
      end
    end
    change_column_null :about_pages, :section_type, false
    add_index :about_pages, :section_type
  end
end
