require "base64"
require "openssl/hmac"

module GDAX

  # Signs requests for GDAX Authentication. See GDAX's [ _Signing a Message_ ](https://docs.gdax.com/#signing-a-message).
  class RequestSigner

    @key : String
    @secret : String
    @passphrase : String

    # `key` is your "CB-ACCESS-KEY", `secret` is your "API-SECRET", and `passphrase` is "PASSPHRASE", as in GDAX's [ _Creating a Request_ ](https://docs.gdax.com/#creating-a-request)
    def initialize(key : String, secret : String, passphrase : String)
      @key = key
      @secret = secret
      @passphrase = passphrase
    end

    # Generates a request signature. Code based on [GDAX's Ruby Sample](https://docs.gdax.com/?ruby#signing-a-message)
    # 
    # `request_path` is the path for your individual request. e.g. `"/orders"`
    # 
    # `body` is a stringified  of your request's body. e.g. `%({"price":"1.0","size":"1.0","side":"buy","product_id":"BTC-USD"})`
    # 
    # `timestamp` is an `Int64` of seconds since Epoch. Defaults to current Epoch.
    # 
    # `method` is a String of the request method. e.g. `"POST"`
    def signature(request_path="", body : String | Hash = "", timestamp : Int64 | Nil = nil, method="GET") : String
      body = body.to_json if body.is_a?(Hash)
      timestamp = Time.now.epoch if !timestamp

      what = "#{timestamp}#{method}#{request_path}#{body}";

      # create a sha256 hmac with the secret
      secret = Base64.decode(@secret)
      hash  = OpenSSL::HMAC.digest(:sha256, secret, what)
      Base64.strict_encode(hash)
    end

  end

end