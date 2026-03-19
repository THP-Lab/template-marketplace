module Twitch
  class SubscriptionSync
    ACTIVE_STATUSES = %w[enabled webhook_callback_verification_pending].freeze
    MANAGED_TYPES = %w[stream.online stream.offline].freeze

    def self.call(...)
      new(...).call
    end

    def initialize(company_information:, callback_base_url: nil, client: nil)
      @company_information = company_information
      @callback_base_url = callback_base_url
      @client = client
    end

    def call
      return disable_integration! unless @company_information.twitch_live_configured?

      Configuration.validate_credentials!
      sync_enabled_integration!
      "Abonnements Twitch synchronises."
    rescue Twitch::Error => e
      mark_sync_error!(e.message)
      raise
    end

    private

    def sync_enabled_integration!
      user = twitch_client.fetch_user_by_login(@company_information.twitch_channel_login)
      raise RequestError, "Impossible de trouver la chaine Twitch configuree." if user.blank?

      callback_url = Configuration.callback_url(callback_base_url: @callback_base_url)
      subscriptions = twitch_client.list_eventsub_subscriptions
      managed = subscriptions.select { |subscription| managed_subscription?(subscription, callback_url) }
      kept = delete_obsolete_subscriptions!(managed, user["id"])

      online_subscription = ensure_subscription!("stream.online", user["id"], callback_url, kept)
      offline_subscription = ensure_subscription!("stream.offline", user["id"], callback_url, kept)

      @company_information.update!(
        twitch_channel_login: user["login"],
        twitch_channel_display_name: user["display_name"].to_s,
        twitch_broadcaster_id: user["id"].to_s,
        twitch_eventsub_online_subscription_id: online_subscription["id"].to_s,
        twitch_eventsub_offline_subscription_id: offline_subscription["id"].to_s,
        twitch_last_synced_at: Time.current,
        twitch_last_sync_error: ""
      )

      Twitch::StreamStateRefresh.call(
        company_information: @company_information,
        broadcaster_user_id: user["id"],
        client: twitch_client
      )
    end

    def disable_integration!
      clear_managed_subscriptions if Configuration.credentials_configured?

      @company_information.update_columns(
        twitch_channel_display_name: "",
        twitch_broadcaster_id: "",
        twitch_eventsub_online_subscription_id: "",
        twitch_eventsub_offline_subscription_id: "",
        twitch_last_synced_at: Time.current,
        twitch_last_sync_error: ""
      )

      TwitchStreamState.current.mark_offline!
      "Live Twitch desactive."
    end

    def clear_managed_subscriptions
      callback_url = Configuration.callback_url(callback_base_url: @callback_base_url)
      twitch_client.list_eventsub_subscriptions.each do |subscription|
        next unless managed_subscription?(subscription, callback_url)

        twitch_client.delete_eventsub_subscription(subscription["id"])
      end
    rescue Twitch::ConfigurationError
      nil
    end

    def delete_obsolete_subscriptions!(subscriptions, broadcaster_user_id)
      kept_subscriptions = []

      subscriptions.group_by { |subscription| subscription["type"] }.each_value do |entries|
        keeper = nil

        entries.each do |subscription|
          if keeper.nil? && subscription_matches?(subscription, broadcaster_user_id) && active_subscription?(subscription)
            keeper = subscription
            kept_subscriptions << subscription
            next
          end

          twitch_client.delete_eventsub_subscription(subscription["id"])
        end
      end

      kept_subscriptions
    end

    def ensure_subscription!(type, broadcaster_user_id, callback_url, kept_subscriptions)
      existing = kept_subscriptions.find do |subscription|
        subscription["type"] == type &&
          subscription_matches?(subscription, broadcaster_user_id) &&
          active_subscription?(subscription) &&
          subscription.dig("transport", "callback") == callback_url
      end

      return existing if existing.present?

      twitch_client.create_eventsub_subscription(
        type: type,
        broadcaster_user_id: broadcaster_user_id,
        callback_url: callback_url,
        secret: Configuration.eventsub_secret
      )
    end

    def managed_subscription?(subscription, callback_url)
      MANAGED_TYPES.include?(subscription["type"]) &&
        subscription.dig("transport", "method") == "webhook" &&
        subscription.dig("transport", "callback") == callback_url
    end

    def subscription_matches?(subscription, broadcaster_user_id)
      subscription.dig("condition", "broadcaster_user_id").to_s == broadcaster_user_id.to_s
    end

    def active_subscription?(subscription)
      ACTIVE_STATUSES.include?(subscription["status"].to_s)
    end

    def mark_sync_error!(message)
      @company_information.update_columns(
        twitch_last_synced_at: Time.current,
        twitch_last_sync_error: message
      )
    end

    def twitch_client
      @client ||= Twitch::Client.new
    end
  end
end
