require "time"

module Twitch
  class EventProcessor
    def self.call(...)
      new(...).call
    end

    def initialize(payload:)
      @payload = payload
      @company_information = CompanyInformation.instance
    end

    def call
      return unless relevant_subscription?

      case subscription_type
      when "stream.online"
        process_stream_online
      when "stream.offline"
        process_stream_offline
      else
        process_revocation
      end
    end

    private

    def process_stream_online
      Twitch::StreamStateRefresh.call(
        company_information: @company_information,
        broadcaster_user_id: event["broadcaster_user_id"],
        event_time: parsed_time(event["started_at"])
      )
    end

    def process_stream_offline
      state = TwitchStreamState.current
      state.update!(
        broadcaster_id: event["broadcaster_user_id"].presence || state.broadcaster_id,
        broadcaster_login: event["broadcaster_user_login"].presence || state.broadcaster_login,
        broadcaster_name: event["broadcaster_user_name"].presence || state.broadcaster_name
      )
      state.mark_offline!(event_time: Time.current)
    end

    def process_revocation
      updates = {
        twitch_last_synced_at: Time.current,
        twitch_last_sync_error: "Abonnement Twitch revoque (#{subscription_type}): #{subscription["status"]}."
      }

      if subscription_type == "stream.online"
        updates[:twitch_eventsub_online_subscription_id] = ""
      elsif subscription_type == "stream.offline"
        updates[:twitch_eventsub_offline_subscription_id] = ""
      end

      @company_information.update_columns(updates)
    end

    def relevant_subscription?
      return false unless @company_information.twitch_live_configured?

      broadcaster_id = subscription.dig("condition", "broadcaster_user_id").to_s.presence || event["broadcaster_user_id"].to_s
      broadcaster_id == @company_information.twitch_broadcaster_id.to_s
    end

    def subscription
      @payload.fetch("subscription", {})
    end

    def event
      @payload.fetch("event", {})
    end

    def subscription_type
      subscription["type"].to_s
    end

    def parsed_time(value)
      Time.iso8601(value.to_s)
    rescue ArgumentError
      Time.current
    end
  end
end
