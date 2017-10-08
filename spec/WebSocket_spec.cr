require "./spec_helper"

describe GDAX::WebSocket do

  gdax_keys = Hash(String, String).from_json ENV["GDAX_KEYS"]
  
  it "instantiates, #run's and #close's" do

    message_recieved = false
    socket_closed = false
    spawn do
      ws = GDAX::WebSocket.new production: true, subscription: {
        "type" => "subscribe",
        "channels" => [{ "name" => "ticker", "product_ids" => ["ETH-EUR"] }]
      }

      ws.on "subscriptions" do |data, event|
        message_recieved = true
        socket_closed = ws.closed?
      end

      ws.on "ticker" do |data, event|
        puts data["price"]
        ws.close
      end

      ws.run
    end

    sleep 3.seconds


    message_recieved.should eq true
  end

  it "instantiates with Authentication, #run's and #close's" do

    message_recieved = false
    socket_closed = false
    
    spawn do
      auth = GDAX::Auth.new key: gdax_keys["CB-ACCESS-KEY"], secret: gdax_keys["API-SECRET"], passphrase: gdax_keys["PASSPHRASE"]

      ws = GDAX::WebSocket.new production: true, subscription: {
        "type" => "subscribe",
        "channels" => [{ "name" => "ticker", "product_ids" => ["ETH-EUR"] }]
      }, auth: auth

      ws.on "subscriptions" do |data, event|
        message_recieved = true
        ws.close
        socket_closed = ws.closed?        
      end
      ws.run
    end

    sleep 3.seconds
    ( message_recieved && socket_closed ).should eq true
  end

end