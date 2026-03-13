require "uri"

module Twitch
  module Configuration
    module_function

    def client_id
      ENV["TWITCH_CLIENT_ID"].to_s
    end

    def client_secret
      ENV["TWITCH_CLIENT_SECRET"].to_s
    end

    def eventsub_secret
      ENV["TWITCH_EVENTSUB_SECRET"].to_s
    end

    def credentials_configured?
      client_id.present? && client_secret.present? && eventsub_secret.present?
    end

    def callback_url(callback_base_url: nil)
      explicit = ENV["TWITCH_EVENTSUB_CALLBACK_URL"].to_s
      return explicit if explicit.present?

      base_url = callback_base_url.to_s.presence || ENV["APP_BASE_URL"].to_s.presence
      raise ConfigurationError, "TWITCH_EVENTSUB_CALLBACK_URL ou APP_BASE_URL doit pointer vers une URL publique en HTTPS." if base_url.blank?

      URI.join(ensure_trailing_slash(base_url), "twitch/eventsub").to_s
    rescue URI::InvalidURIError
      raise ConfigurationError, "L'URL de callback Twitch est invalide."
    end

    def validate_credentials!
      return if credentials_configured?

      raise ConfigurationError, "Configurer TWITCH_CLIENT_ID, TWITCH_CLIENT_SECRET et TWITCH_EVENTSUB_SECRET avant d'activer Twitch."
    end

    def ensure_trailing_slash(value)
      value.end_with?("/") ? value : "#{value}/"
    end
    private_class_method :ensure_trailing_slash
  end
end
