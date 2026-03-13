class Twitch::LiveStatePresenter
  def initialize(company_information:, stream_state:, request:)
    @company_information = company_information
    @stream_state = stream_state
    @request = request
  end

  def as_json(*)
    {
      enabled: @company_information.twitch_live_configured?,
      live: live?,
      stream_id: stream_id,
      popup_title: @company_information.twitch_popup_title_or_default,
      channel_login: @company_information.twitch_channel_login,
      channel_name: channel_name,
      title: @stream_state.title.presence,
      game_name: @stream_state.game_name.presence,
      viewer_count: @stream_state.viewer_count.to_i,
      started_at: @stream_state.started_at&.iso8601,
      started_at_label: started_at_label,
      thumbnail_url: @stream_state.thumbnail_url,
      channel_url: channel_url,
      embed_url: embed_url,
      last_synced_at: @stream_state.last_synced_at&.iso8601
    }
  end

  private

  def live?
    @stream_state.online? && state_matches_configured_channel?
  end

  def stream_id
    @stream_state.stream_id.presence if live?
  end

  def channel_name
    @company_information.twitch_channel_display_name.presence ||
      @stream_state.broadcaster_name.presence ||
      @company_information.twitch_channel_login
  end

  def channel_url
    return if @company_information.twitch_channel_login.blank?

    "https://www.twitch.tv/#{ERB::Util.url_encode(@company_information.twitch_channel_login)}"
  end

  def embed_url
    return if @company_information.twitch_channel_login.blank?

    "https://player.twitch.tv/?channel=#{ERB::Util.url_encode(@company_information.twitch_channel_login)}&parent=#{ERB::Util.url_encode(@request.host)}&muted=true&autoplay=true"
  end

  def started_at_label
    return if @stream_state.started_at.blank?

    I18n.l(@stream_state.started_at, format: :short)
  rescue I18n::ArgumentError
    nil
  end

  def state_matches_configured_channel?
    broadcaster_id = @company_information.twitch_broadcaster_id.to_s
    return @stream_state.broadcaster_login.to_s.casecmp?(@company_information.twitch_channel_login.to_s) if broadcaster_id.blank?

    @stream_state.broadcaster_id.to_s == broadcaster_id
  end
end
