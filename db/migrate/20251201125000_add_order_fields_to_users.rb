class AddOrderFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :address, :string
    add_column :users, :zipcode, :string
    add_column :users, :city, :string
    add_column :users, :country, :string
    add_column :users, :phone, :string
    add_column :users, :cgu_accepted, :boolean, default: false, null: false
  end
end
