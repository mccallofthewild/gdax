require "./spec_helper"


describe GDAX::RequestSigner do

  gdax_keys = Hash(String, String).from_json ENV["GDAX_KEYS"]

  it "#initialize" do 
    rs = GDAX::RequestSigner.new gdax_keys["CB-ACCESS-KEY"], gdax_keys["API-SECRET"], gdax_keys["PASSPHRASE"]
    true.should eq true
  end

  it "#signature" do  
    rs = GDAX::RequestSigner.new gdax_keys["CB-ACCESS-KEY"], gdax_keys["API-SECRET"], gdax_keys["PASSPHRASE"]
    (rs.signature.size > 10).should eq true  
  end

end