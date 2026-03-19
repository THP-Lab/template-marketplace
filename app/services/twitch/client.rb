require "json"
require "net/http"
require "uri"

module Twitch
  class Client
    API_BASE_URL = "https://api.twitch.tv".freeze
    OAUTH_BASE_URL = "https://id.twitch.tv".freeze
    TOKEN_CACHE_KEY = "twitch/app_access_token".freeze

    def initialize
      Configuration.validate_credentials!
    end

    def fetch_user_by_login(login)
      response = get("/helix/users", login: login)
      response.fetch("data", []).first
    end

    def fetch_stream_by_user_id(user_id)
      response = get("/helix/streams", user_id: user_id)
      response.fetch("data", []).first
    end

    def list_eventsub_subscriptions
      subscriptions = []
      cursor = nil

      loop do
        params = { first: 100 }
        params[:after] = cursor if cursor.present?
        response = get("/helix/eventsub/subscriptions", params)
        subscriptions.concat(response.fetch("data", []))
        cursor = response.dig("pagination", "cursor")
        break if cursor.blank?
      end

      subscriptions
    end

    def create_eventsub_subscription(type:, broadcaster_user_id:, callback_url:, secret:)
      post("/helix/eventsub/subscriptions", {
        type: type,
        version: "1",
        condition: { broadcaster_user_id: broadcaster_user_id },
        transport: {
          method: "webhook",
          callback: callback_url,
          secret: secret
        }
      }).fetch("data", []).first
    end

    def delete_eventsub_subscription(id)
      delete("/helix/eventsub/subscriptions", id: id)
      true
    end

    private

    def get(path, params = {})
      request(:get, path, params: params)
    end

    def post(path, body)
      request(:post, path, body: body)
    end

    def delete(path, params = {})
      request(:delete, path, params: params)
    end

    def request(method, path, params: nil, body: nil)
      uri = build_api_uri(path, params)
      request_class = request_class_for(method)
      http_request = request_class.new(uri)
      http_request["Client-Id"] = Configuration.client_id
      http_request["Authorization"] = "Bearer #{app_access_token}"
      http_request["Content-Type"] = "application/json" if body.present?
      http_request.body = JSON.dump(body) if body.present?

      parse_response(perform_request(uri, http_request))
    end

    def build_api_uri(path, params)
      uri = URI.join(API_BASE_URL, path)
      uri.query = params.to_query if params.present?
      uri
    end

    def perform_request(uri, http_request)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10
      http.open_timeout = 5
      http.request(http_request)
    end

    def parse_response(response)
      body = response.body.to_s
      payload = body.present? ? JSON.parse(body) : {}
      return payload if response.is_a?(Net::HTTPSuccess)

      message = payload["message"].presence || "Requete Twitch en echec (#{response.code})."
      raise RequestError, message
    rescue JSON::ParserError
      raise RequestError, "Reponse Twitch invalide."
    end

    def app_access_token
      cached_token = Rails.cache.read(TOKEN_CACHE_KEY)
      return cached_token if cached_token.present?

      token, expires_in = fetch_app_access_token
      Rails.cache.write(TOKEN_CACHE_KEY, token, expires_in: [expires_in - 60, 60].max.seconds)
      token
    end

    def fetch_app_access_token
      uri = URI.join(OAUTH_BASE_URL, "/oauth2/token")
      uri.query = {
        client_id: Configuration.client_id,
        client_secret: Configuration.client_secret,
        grant_type: "client_credentials"
      }.to_query

      response = perform_request(uri, Net::HTTP::Post.new(uri))
      payload = parse_response(response)
      token = payload["access_token"].presence
      expires_in = payload["expires_in"].to_i
      raise RequestError, "Token Twitch introuvable." if token.blank?

      [token, expires_in]
    end

    def request_class_for(method)
      {
        get: Net::HTTP::Get,
        post: Net::HTTP::Post,
        delete: Net::HTTP::Delete
      }.fetch(method)
    end
  end
end
