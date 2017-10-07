require "./spec_helper"


require "yaml"
require "file"

Proc(Void).new do

  file_name = ".gdax_keys.yml"

  if File.exists?(file_name)
    contents = File.read(file_name)
    result = YAML.parse(contents)
    ENV["GDAX_KEYS"] = result.as_h.to_json
  end
  
end.call


describe GDAX do
end
