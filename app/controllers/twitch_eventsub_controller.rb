class TwitchEventsubController < ActionController::Base
  skip_forgery_protection

  def create
    body = request.raw_post
    payload = JSON.parse(body)
    verifier = Twitch::WebhookVerifier.new(headers: request.headers, body: body)
    verifier.verify!

    case verifier.message_type
    when "webhook_callback_verification"
      render plain: payload["challenge"].to_s, content_type: "text/plain"
    when "notification", "revocation"
      Twitch::EventProcessor.call(payload: payload)
      head :no_content
    else
      head :bad_request
    end
  rescue JSON::ParserError
    head :bad_request
  rescue Twitch::SignatureError
    head :forbidden
  rescue Twitch::ConfigurationError
    head :service_unavailable
  rescue Twitch::Error => e
    Rails.logger.error("[TwitchEventsub] #{e.class}: #{e.message}")
    head :unprocessable_entity
  end
end
