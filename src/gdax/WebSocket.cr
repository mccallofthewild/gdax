require "http"
require "json"
require "event_emitter"

module GDAX

  # GDAX [WebSocket API](https://docs.gdax.com/#websocket-feed) wrapper.
  class WebSocket
    
    # GDAX's API URL ()
    DEFAULT_PRODUCTION_HOST = "wss://ws-feed.gdax.com"
    
    # GDAX's Sandbox API URL
    DEFAULT_SANDBOX_HOST = "wss://ws-feed.sandbox.gdax.com"

    alias EmitArgType = Tuple(String, JSON::Any)
    @emitter = EventEmitter::Base( String, EmitArgType ).new
    
    # 
    # 
    # `uri` is the WebSocket URI. Defaults to sandbox URI unless `production` is set to `true`
    # 
    # `headers` are any additional headers you would like to add to the connection.
    # 
    # Unlike Crystal's default `WebSocket`, `GDAX::WebSocket` runs immediately upon instantiation.
    # To disable this, set `run_on_init` to false.
    def initialize(
      subscription : Hash = { "type" => "subscribe" },
      production = false,
      uri : URI | String = default_host(production),
      headers = HTTP::Headers.new,
      run_on_init = true
    )
      @ws = HTTP::WebSocket.new uri, headers

      @ws.on_close do |_|
        puts "CLOSED"
      end

      @ws.on_message do |message|
        puts message
        handle_message message
      end

      @ws.send(%(
        {
            "type": "subscribe",
            "channels": [{ "name": "heartbeat", "product_ids": ["ETH-EUR"] }]
        }
      ))

    end

    def run 
      @ws.run
    end

    private def default_host(production) : String
      production ? DEFAULT_PRODUCTION_HOST : DEFAULT_SANDBOX_HOST
    end

    def on(event : String, &block : Proc(
      *EmitArgType,
      Void
    ))
      @emitter.on event, ->(x : EmitArgType) do 
        block.call(*x)
      end
    end

    private def handle_message(message : String)
      json_data = JSON.parse(message)
      gdax_event = json_data["type"].as_s

      @emitter.emit gdax_event, {
        gdax_event,
        json_data
      }
    end
    
    def handle_price(json : JSON::Any)
      last_price : Float64 = 0.to_f64
      
      begin
        price_string = json["price"].as_s

        price = price_string.to_f64

        if price
        end

      rescue e
        puts message
      end

    end

  end
end
