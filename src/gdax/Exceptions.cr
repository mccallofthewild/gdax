# Custom GDAX Exceptions
module GDAX::Exceptions

  # Typically raised when a WebSocket message with `error` type comes back.
  class ResponseException < Exception
  end

end