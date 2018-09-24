require "spec"
require "../src/gdax"


require "yaml"
require "file"

REQ_WAIT_TIME = 2

Proc(Void).new do

  file_name = ".gdax_keys.yml"

  if File.exists?(file_name)
    contents = File.read(file_name)
    result = YAML.parse(contents)
    ENV["CB-ACCESS-KEY"] = result["CB-ACCESS-KEY"].as_s?
    ENV["API-SECRET"] = result["API-SECRET"].as_s?
    ENV["PASSPHRASE"] = result["PASSPHRASE"].as_s?
  end
  
  ENV["GDAX_KEYS"] = {
    "CB-ACCESS-KEY" => ENV["CB-ACCESS-KEY"],
    "API-SECRET" => ENV["API-SECRET"],
    "PASSPHRASE" => ENV["PASSPHRASE"]
  }.to_json

  
end.call
