class CreateTwitchStreamStates < ActiveRecord::Migration[8.1]
  def change
    create_table :twitch_stream_states do |t|
      t.boolean :online, default: false, null: false
      t.string :stream_id
      t.string :title
      t.string :game_name
      t.string :thumbnail_url_template
      t.datetime :started_at
      t.integer :viewer_count, default: 0, null: false
      t.string :broadcaster_id
      t.string :broadcaster_login
      t.string :broadcaster_name
      t.datetime :last_event_at
      t.datetime :last_synced_at

      t.timestamps
    end
  end
end
