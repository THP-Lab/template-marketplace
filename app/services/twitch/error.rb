module Twitch
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class RequestError < Error; end
  class SignatureError < Error; end
end
