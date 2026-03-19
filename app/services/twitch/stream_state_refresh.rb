module Twitch
  class StreamStateRefresh
    def self.call(...)
      new(...).call
    end

    def initialize(company_information:, broadcaster_user_id: nil, client: nil, event_time: Time.current)
      @company_information = company_information
      @broadcaster_user_id = broadcaster_user_id.presence || company_information.twitch_broadcaster_id
      @client = client
      @event_time = event_time
    end

    def call
      state = TwitchStreamState.current
      sync_identity!(state)

      if @company_information.twitch_live_configured? && @broadcaster_user_id.present?
        stream = twitch_client.fetch_stream_by_user_id(@broadcaster_user_id)
        return state.mark_live!(stream: stream, event_time: @event_time) if stream.present?
      end

      state.mark_offline!(event_time: @event_time)
    end

    private

    def sync_identity!(state)
      state.update!(
        broadcaster_id: @broadcaster_user_id,
        broadcaster_login: @company_information.twitch_channel_login.presence,
        broadcaster_name: @company_information.twitch_channel_display_name.presence
      )
    end

    def twitch_client
      @client ||= Twitch::Client.new
    end
  end
end
