require "./spec_helper"

describe GDAX::WebSocket do

  gdax_keys = Hash(String, String).from_json ENV["GDAX_KEYS"]
  
  # while it's not optimal to have three methods wrapped up in one test, closing the socket protects us from hitting rate limits.
  # and if we're going to close the socket, we might as well test the `#close` method while we're at it.

  it "#instantiate's, #run's and #close's" do

    message_recieved = false
    socket_closed = false 
    closed_method_result = false
    on_close_invoked = false

    spawn do
      ws = GDAX::WebSocket.new production: true, subscription: {
        "type" => "subscribe",
        "channels" => [{ "name" => "ticker", "product_ids" => ["ETH-EUR"] }]
      }

      ws.on "subscriptions" do |data|
        message_recieved = true
        socket_closed = ws.closed?
      end

      ws.on "ticker" do |data|
        ws.close
        closed_method_result = !!ws.closed?
      end

      ws.on_close do |arg|
        on_close_invoked = true
      end

      ws.run
    end

    sleep REQ_WAIT_TIME.seconds

    recieved_message_passed = false
    it "recieved message" do
      recieved_message_passed = true      
      message_recieved.should eq true
    end

    it "#on" do 
      recieved_message_passed.should eq true 
    end

    it "closed socket" do 
      socket_closed.should eq true
    end

    it "#closed?" do 
      closed_method_result.should eq socket_closed
    end

    it "#on_close" do 
      on_close_invoked.should eq socket_closed
    end

  end

  it "#instantiate's with Authentication, #run's and #close's" do

    message_recieved = false
    socket_closed = false
    
    spawn do
      auth = GDAX::Auth.new key: gdax_keys["CB-ACCESS-KEY"], secret: gdax_keys["API-SECRET"], passphrase: gdax_keys["PASSPHRASE"]

      ws = GDAX::WebSocket.new production: true, subscription: {
        "type" => "subscribe",
        "channels" => [{ "name" => "ticker", "product_ids" => ["ETH-EUR"] }]
      }, auth: auth

      ws.on "subscriptions" do |data|
        message_recieved = true
        ws.close
        socket_closed = ws.closed?        
      end

      ws.run
    end

    sleep REQ_WAIT_TIME.seconds

    it "recieved message" do
      message_recieved.should eq true
    end

    it "closed socket" do 
      socket_closed.should eq true
    end

  end

end