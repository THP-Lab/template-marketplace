class AllowOrdersWithoutUser < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :orders, :users
    change_column_null :orders, :user_id, true
    add_foreign_key :orders, :users, on_delete: :nullify
  end
end
