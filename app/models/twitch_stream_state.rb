class TwitchStreamState < ApplicationRecord
  def self.current
    first_or_create!(online: false)
  end

  def mark_offline!(event_time: Time.current)
    update!(
      online: false,
      stream_id: nil,
      title: nil,
      game_name: nil,
      thumbnail_url_template: nil,
      started_at: nil,
      viewer_count: 0,
      last_event_at: event_time,
      last_synced_at: Time.current
    )
  end

  def mark_live!(stream:, event_time: Time.current)
    update!(
      online: true,
      stream_id: stream["id"],
      title: stream["title"],
      game_name: stream["game_name"],
      thumbnail_url_template: stream["thumbnail_url"],
      started_at: parse_time(stream["started_at"]),
      viewer_count: stream["viewer_count"].to_i,
      broadcaster_id: stream["user_id"],
      broadcaster_login: stream["user_login"],
      broadcaster_name: stream["user_name"],
      last_event_at: event_time,
      last_synced_at: Time.current
    )
  end

  def thumbnail_url(width: 640, height: 360)
    return if thumbnail_url_template.blank?

    thumbnail_url_template
      .gsub("{width}", width.to_s)
      .gsub("{height}", height.to_s)
  end

  private

  def parse_time(value)
    return value if value.is_a?(Time) || value.is_a?(ActiveSupport::TimeWithZone)
    return if value.blank?

    Time.zone.parse(value.to_s)
  rescue ArgumentError
    nil
  end
end
