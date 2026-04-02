class AddCustomerSnapshotFieldsToOrders < ActiveRecord::Migration[8.1]
  class MigrationOrder < ActiveRecord::Base
    self.table_name = "orders"
  end

  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  def up
    add_column :orders, :customer_email, :string
    add_column :orders, :shipping_first_name, :string
    add_column :orders, :shipping_last_name, :string
    add_column :orders, :shipping_address, :string
    add_column :orders, :shipping_zipcode, :string
    add_column :orders, :shipping_city, :string
    add_column :orders, :shipping_country, :string
    add_column :orders, :shipping_phone, :string

    backfill_shipping_snapshot_from_users
  end

  def down
    remove_column :orders, :shipping_phone
    remove_column :orders, :shipping_country
    remove_column :orders, :shipping_city
    remove_column :orders, :shipping_zipcode
    remove_column :orders, :shipping_address
    remove_column :orders, :shipping_last_name
    remove_column :orders, :shipping_first_name
    remove_column :orders, :customer_email
  end

  private

  def backfill_shipping_snapshot_from_users
    say_with_time "Backfill shipping snapshot from existing users" do
      MigrationOrder.reset_column_information

      MigrationOrder.where.not(user_id: nil).find_each(batch_size: 200) do |order|
        user = MigrationUser.find_by(id: order.user_id)
        next unless user

        order.update_columns(
          customer_email: order.customer_email.presence || user.email,
          shipping_first_name: order.shipping_first_name.presence || user.first_name,
          shipping_last_name: order.shipping_last_name.presence || user.last_name,
          shipping_address: order.shipping_address.presence || user.address,
          shipping_zipcode: order.shipping_zipcode.presence || user.zipcode,
          shipping_city: order.shipping_city.presence || user.city,
          shipping_country: order.shipping_country.presence || user.country,
          shipping_phone: order.shipping_phone.presence || user.phone
        )
      end
    end
  end
end
