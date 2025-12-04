class RenameTypeInProducts < ActiveRecord::Migration[8.1]
  def change
    rename_column :products, :type, :category
  end
end
