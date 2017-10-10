require "http"
require "json"
require "event_emitter"

module GDAX

  # GDAX [WebSocket API](https://docs.gdax.com/#websocket-feed) wrapper.
  # 
  # ```
  # ws = GDAX::WebSocket.new production: true, subscription: {
  #   "type" => "subscribe",
  #   "channels" => [{ "name" => "heartbeat", "product_ids" => ["ETH-EUR"] }]
  # }
  #
  # ws.on "subscriptions" do |data, event|
  #   puts "GDAX CONNECTED"
  # end
  #
  # ws.run
  # ```
  class WebSocket
    
    # GDAX's API URL
    DEFAULT_PRODUCTION_HOST = "wss://ws-feed.gdax.com"
    
    # GDAX's Sandbox API URL
    DEFAULT_SANDBOX_HOST = "wss://ws-feed.sandbox.gdax.com"

    # The unsplatted arguments an event listener can accept.
    alias EmitArgType = Tuple(JSON::Any, String)

    @emitter = EventEmitter::Base( String, EmitArgType ).new
    
    # `subscription` is your [ _GDAX Subscribe Request_ ](https://docs.gdax.com/#subscribe) in the form of a `Hash`.
    # 
    # `uri` is the WebSocket URI. Defaults to sandbox URI unless `production` is set to `true`
    # 
    # `headers` are any additional headers you would like to add to the connection.
    # 
    # If `production` is false, sandbox URI will be used by default.
    # 
    # `auth` can be passed to [sign/authenticate over WebSockets](https://docs.gdax.com/#subscribe).
    def initialize(
      subscription : Hash,
      production = true,
      uri : URI | String = default_host(production),
      headers = HTTP::Headers.new,
      auth : GDAX::Auth? = nil
    )

      if auth 
        subscription = subscription.merge auth.signed_hash request_path: "/users/self", method: "GET"
      end

      @ws = HTTP::WebSocket.new uri, headers

      @ws.on_message do |message|
        handle_message message
      end

      @ws.send subscription.to_json
    end

    # runs the WebSocket (invoke after adding "subscriptions" event listeners; must be called for the WebSocket to run)
    # alias to `HTTP::WebSocket`'s `run` method.
    def run(*args)
      @ws.run(*args)
    end

    # closes the WebSocket
    # alias to `HTTP::WebSocket`'s `close` method.
    def close(*args)
      @ws.close(*args)
    end

    # Returns Bool based on whether WebSocket is closed.
    # alias to `HTTP::WebSocket`'s `closed?` method.
    def closed?(*args)
      @ws.closed?(*args)
    end

    # alias to `HTTP::WebSocket`'s `on_close` method.
    def on_close(&on_close : String -> )
      @ws.on_close do |close_message|
        on_close.call close_message 
      end
    end

    # Adds event listener for events based on [ _GDAX's message `type`'s_ ](https://docs.gdax.com/#protocol-overview).
    # Takes in `String` of the event to listen for and a block to run when the event fires.
    # The block is passed two arguments: the first being the `JSON::Any` response data from GDAX, and the second being the event itself.
    # e.g.
    # ```crystal
    # ws.on "subscriptions" do |data, event|
    #   message_recieved = true
    # end
    # ```
    def on(event : String, &block : Proc(
      *EmitArgType,
      Void
    ))
      @emitter.on event, ->(x : EmitArgType) do 
        block.call(*x)
      end
    end
    

    # Returns host to default to depending on environment
    private def default_host(production) : String
      production ? DEFAULT_PRODUCTION_HOST : DEFAULT_SANDBOX_HOST
    end

    # handles GDAX messages and emits their `type`'s as events
    private def handle_message(message : String)
      json_data = JSON.parse(message)
      gdax_event = json_data["type"].as_s
      
      @emitter.emit gdax_event, {
        json_data,
        gdax_event
      }
      if gdax_event == "error" 
        raise GDAX::Exceptions::ResponseException.new message: json_data["message"].as_s
      end
    end
    
  end
end
