require "http"

module GDAX

  # An [`HTTP::Client`](https://crystal-lang.org/api/HTTP/Client.html) for interacting with the [GDAX Client API](https://docs.gdax.com/#api).
  # ```
  # auth = GDAX::Auth.new ENV["CB-ACCESS-KEY"], ENV["API-SECRET"], ENV["PASSPHRASE"]
  # client = GDAX::Client.new auth
  
  # client.get "/products/BTC-USD/trades" do |response|
  #   success = true
  # end
  # ```
  class Client < HTTP::Client

    # GDAX's API URL
    DEFAULT_PRODUCTION_HOST = "api.gdax.com"

    # GDAX's Sandbox API URL
    DEFAULT_SANDBOX_HOST = "api-public.sandbox.gdax.com"

    # A constructor for an authenticated client (for access to Private _and_ Public endpoints).
    # `auth` is a `GDAX::Auth` instance containing your API keys.
    # `host` is the host uri string. This defaults to `DEFAULT_PRODUCTION_HOST` if `production` is not set to false.
    def initialize(
      @auth : GDAX::Auth,
      production = true,
      @host = default_host(production),
      **args
    )

      super(
        **args,
        host: @host,
        tls: true
      )

      self.before_request do |request|

        request.headers.merge! authenticated_headers(          
          request_path: request.path,
          body: request.body.to_s,
          timestamp: Time.now.epoch,
          method: request.method
        )

      end

    end

    # A constructor for an unauthenticated client (for access to Public endpoints only).
    # `host` is the host uri string. This defaults to `DEFAULT_PRODUCTION_HOST` if `production` is not set to false.
    def initialize(
      production = true,
      @host = default_host(production),
      **args
    )
      super(
        **args,
        host: @host,
        tls: true
      )

      @auth = GDAX::Auth.new "", "", ""

      self.before_request do |request|
        request.headers.merge! base_headers
      end

    end

    # Returns standard, unauthenticated headers placed on every request.
    def base_headers 
      HTTP::Headers{
        "Content-Type" => "application/json"
      }
    end

    # Returns authenticated headers; Placed on every request if `Client` is authenticated.
    # All arguments are passed directly to `GDAX::Auth#signed_headers`.
    def authenticated_headers(
      request_path="", 
      body : String | Hash = "", 
      timestamp : Int64 = Time.now.epoch, 
      method="GET"
    )
      headers = base_headers
      headers.merge! @auth.signed_headers request_path, body, timestamp, method
      headers
    end
    
    # Returns default host based on `production` argument.
    private def default_host(production)
      production ? DEFAULT_PRODUCTION_HOST : DEFAULT_SANDBOX_HOST
    end

  end

end