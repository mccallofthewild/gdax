require "./spec_helper"
require "json"

describe GDAX::Client do

  gdax_keys = Hash(String, String).from_json ENV["GDAX_KEYS"]
  auth_args = { gdax_keys["CB-ACCESS-KEY"], gdax_keys["API-SECRET"], gdax_keys["PASSPHRASE"] }

  it "#initialize w/ Auth" do  
    auth = GDAX::Auth.new *auth_args
    client = GDAX::Client.new auth
    true.should be_true
  end

  it "#initialize w/o Auth" do 
    client = GDAX::Client.new
    true.should be_true
  end

  it "Authenticated #get's" do 
    success = false  
    auth = GDAX::Auth.new *auth_args
    client = GDAX::Client.new auth

    client.get "/products/BTC-USD/trades" do |response|
      success = true
    end

    sleep REQ_WAIT_TIME.seconds
    success.should be_true
  end


  it "Unauthenticated #get's" do
    success = false
    client = GDAX::Client.new

    client.get "/orders?before=2&limit=30" do |response|
      success = true
    end
    sleep REQ_WAIT_TIME.seconds
    success.should eq true
  end

  it "#base_headers" do 
    client = GDAX::Client.new  
    ( client.base_headers.is_a? HTTP::Headers ).should be_true
  end

end
