require "base64"
require "openssl/hmac"
require "http"

module GDAX


  # Signs requests for GDAX Authentication. See GDAX's [ _Signing a Message_ ](https://docs.gdax.com/#signing-a-message).
  class Auth

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

    # Returns full, signed authentication object as a `Hash`.
    def signed_hash(request_path="", body : String | Hash = "", timestamp : Int64 = Time.now.epoch, method="GET")
      return {
        "CB-ACCESS-KEY" => @key,
        "CB-ACCESS-PASSPHRASE" => @passphrase,
        "CB-ACCESS-TIMESTAMP" => timestamp,
        "CB-ACCESS-SIGN" => signature request_path, body, timestamp, method
      }
    end

    # Returns full, signed authentication object as a `HTTP::Headers` instance.
    def signed_headers(request_path="", body : String | Hash = "", timestamp : Int64 = Time.now.epoch, method="GET")
      auth_obj = self.signed_hash request_path, body, timestamp, method
      HTTP::Headers{
        "CB-ACCESS-KEY" => @key,
        "CB-ACCESS-PASSPHRASE" => @passphrase,
        "CB-ACCESS-TIMESTAMP" => timestamp.to_s,
        "CB-ACCESS-SIGN" => signature request_path, body, timestamp, method
      }
    end


  end

end