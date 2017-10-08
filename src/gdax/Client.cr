require "http"

module GDAX

  # An `HTTP::Client` for interacting with the [GDAX REST API](https://docs.gdax.com/#api)
  class REST < HTTP::Client

    # GDAX's API URL ()
    DEFAULT_PRODUCTION_HOST = "https://api.gdax.com"

    # GDAX's Sandbox API URL
    DEFAULT_SANDBOX_HOST = "https://api-public.sandbox.gdax.com"


    # `host` is the host uri string. This defaults to `DEFAULT_PRODUCTION_HOST` if `production` is not set to false.
    def initialize(
      @host = default_host(),
      production = true
    )
      super @host
    end

    private def default_host
      GDAX_ENV_PRODUCTION ? DEFAULT_PRODUCTION_HOST : DEFAULT_SANDBOX_HOST
    end

  end

end