# GDAX

A Crystal library for interacting with GDAX's REST and WebSocket API's.

### Visit the [API Documentation](https://mccallofthewild.github.io/gdax/) for a more in-depth look at the library's functionality.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  gdax:
    github: mccallofthewild/gdax
```

## Usage

Begin by requiring `"gdax"`.

```crystal
require "gdax"
```

### `GDAX::WebSocket` 
> Interact with the GDAX WebSocket Feed

#### Basic 
It's recommended that you [spawn a Fiber](https://crystal-lang.org/docs/guides/concurrency.html) around each `GDAX::WebSocket` you instantiate in order to achieve concurrency.
```crystal
spawn do
  ws = GDAX::WebSocket.new production: true, subscription: {
    "type" => "subscribe",
    "channels" => [{ "name" => "ticker", "product_ids" => ["ETH-EUR"] }]
  }

  ws.run
end
Fiber.yield
```

#### `GDAX::WebSocket#on`
Use the `#on` method to add event listeners to a `GDAX::WebSocket`.

Events are based on [ _GDAX's message `type`'s_ ](https://docs.gdax.com/#protocol-overview).

`#on` takes in a `String` of the event to listen for and a block to call when the event is fired.
The block is passed two arguments: the first being the `JSON::Any` response data from GDAX, and the second being the event itself.

```crystal 
ws.on "subscriptions" do |data, event|
  puts "subscribed!"
end
```

Though event listeners _can_ be added dynamically on runtime, to avoid missing events, it is recommended that all listeners be added prior to invoking `GDAX::WebSocket#run`.

e.g.
```crystal
spawn do
  ws = GDAX::WebSocket.new production: true, subscription: {
    "type" => "subscribe",
    "channels" => [{ "name" => "ticker", "product_ids" => ["ETH-EUR"] }]
  }

  ws.on "subscriptions" do |data, event|
    puts "subscribed!"
  end

  ws.on "ticker" do |data, event|
    puts data["price"] #=> e.g. 264.10000000
  end

  ws.run
end
Fiber.yield
```

#### Authenticating
It is possible to authenticate yourself when subscribing to the websocket feed. See the [GDAX documentation on the subject](https://docs.gdax.com/#subscribe).

To authenticate, pass named argument, `auth` to the `GDAX::WebSocket` with a `GDAX::Auth` instance.
See [ _Authentication_ ](https://docs.gdax.com/#authentication) for help getting your `key`, `secret`, and `passphrase`.

It is recommended that you store your `key`, `secret`, and `passphrase` as environment variables.

```crystal
spawn do
  auth = GDAX::Auth.new key: ENV["CB-ACCESS-KEY"], secret: ENV["API-SECRET"], passphrase: ENV["PASSPHRASE"]

  ws = GDAX::WebSocket.new production: true, subscription: {
    "type" => "subscribe",
    "channels" => [{ "name" => "ticker", "product_ids" => ["ETH-EUR"] }]
  }, auth: auth
  
  ws.on "subscriptions" do |data, event|
    puts "subscribed!"
  end
  ws.run
end
```



See [the API Documentation](https://github.com/mccallofthewild/gdax/GDAX/WebSocket.html) for more information on `GDAX::WebSocket`.


## Contributing

1. Fork it ( https://github.com/mccallofthewild/gdax/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [McCall Alexander](https://github.com/mccallofthewild) mccallofthewild - creator, maintainer
