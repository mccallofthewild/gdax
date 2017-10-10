require "./spec_helper"


describe GDAX::Auth do

  gdax_keys = Hash(String, String).from_json ENV["GDAX_KEYS"]
  auth_args = { gdax_keys["CB-ACCESS-KEY"], gdax_keys["API-SECRET"], gdax_keys["PASSPHRASE"] }
  
  it "#initialize" do 
    rs = GDAX::Auth.new *auth_args
    true.should eq true
  end

  it "#signature" do  
    rs = GDAX::Auth.new *auth_args
    (rs.signature.size > 10).should eq true  
  end

  it "#signed_hash" do  
    rs = GDAX::Auth.new *auth_args 
    ( rs.signed_hash.is_a? Hash ).should eq true
  end

  it "#signed_headers" do  
    rs = GDAX::Auth.new *auth_args 
    ( rs.signed_headers.is_a? HTTP::Headers ).should eq true
  end

end