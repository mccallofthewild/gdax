require "./spec_helper"

describe GDAX::WebSocket do

  it "instantiates" do
    puts "running"
    message_recieved = false
    spawn do
      ws = GDAX::WebSocket.new production: true
      puts "passed ws"
      ws.on "subscriptions" do |event, data|
        message_recieved = true
      end
      ws.run
    end

    sleep 3.seconds

    message_recieved.should eq true
  end

end