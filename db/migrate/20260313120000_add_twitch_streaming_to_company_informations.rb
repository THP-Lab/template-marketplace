class AddTwitchStreamingToCompanyInformations < ActiveRecord::Migration[8.1]
  def change
    change_table :company_informations, bulk: true do |t|
      t.boolean :twitch_live_enabled, default: false, null: false
      t.string :twitch_channel_login, default: "", null: false
      t.string :twitch_channel_display_name, default: "", null: false
      t.string :twitch_broadcaster_id, default: "", null: false
      t.string :twitch_popup_title, default: "", null: false
      t.datetime :twitch_last_synced_at
      t.text :twitch_last_sync_error
      t.string :twitch_eventsub_online_subscription_id, default: "", null: false
      t.string :twitch_eventsub_offline_subscription_id, default: "", null: false
    end
  end
end
