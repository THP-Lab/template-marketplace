require "openssl"

module Twitch
  class WebhookVerifier
    MESSAGE_TTL = 10.minutes

    def initialize(headers:, body:)
      @headers = headers
      @body = body.to_s
    end

    def verify!
      Configuration.validate_credentials!
      validate_signature!
      validate_timestamp!
      prevent_replay!
      true
    end

    def message_type
      header("Twitch-Eventsub-Message-Type")
    end

    private

    def validate_signature!
      expected = "sha256=#{OpenSSL::HMAC.hexdigest("sha256", Configuration.eventsub_secret, signed_message)}"
      provided = header("Twitch-Eventsub-Message-Signature")
      secure_compare!(expected, provided)
    end

    def validate_timestamp!
      timestamp = Time.iso8601(header("Twitch-Eventsub-Message-Timestamp"))
      return if timestamp >= MESSAGE_TTL.ago

      raise SignatureError, "Message Twitch expire."
    rescue ArgumentError
      raise SignatureError, "Timestamp Twitch invalide."
    end

    def prevent_replay!
      cache_key = "twitch/eventsub/#{header("Twitch-Eventsub-Message-Id")}"
      written = Rails.cache.write(cache_key, true, expires_in: MESSAGE_TTL, unless_exist: true)
      return if written

      raise SignatureError, "Message Twitch deja traite."
    end

    def secure_compare!(expected, provided)
      unless expected.bytesize == provided.to_s.bytesize &&
             ActiveSupport::SecurityUtils.secure_compare(expected, provided.to_s)
        raise SignatureError, "Signature Twitch invalide."
      end
    end

    def signed_message
      [
        header("Twitch-Eventsub-Message-Id"),
        header("Twitch-Eventsub-Message-Timestamp"),
        @body
      ].join
    end

    def header(name)
      @headers[name].to_s
    end
  end
end
