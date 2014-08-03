Virtex
==========

A thin wrapper around the CaVirtex API

## Usage

See the CaVirtex API docs and source code for more information

### Unauthenticated requests

``` ruby
require 'virtex'
@virtex = Virtex::Client.new
```

#### Orderbook

```ruby
book = @virtex.orderbook('BTCCAD').orderbook

best_bid = book.bids.first
expect(best_bid[0]).to eq(631.481850000) # Price
expect(best_bid[1]).to eq(1.367900000) # Size

best_ask = asks.last
expect(best_ask[0]).to eq(634.974840000)
expect(best_ask[1]).to eq(9.727400000)
```

#### Tradebook

```ruby
trades = @virtex.tradebook('BTCCAD').trades
latest = trades.first
```

#### Ticker

```ruby
ticker = @virtex.ticker("BTCCAD").ticker.BTCCAD
```

### Authenticated requests

```ruby
require 'virtex'
@virtex = Virtex::Client.new(ENV['VIRTEX_API_KEY'], ENV['VIRTEX_API_SECRET'])
```

#### View Balance

```ruby
expect(@virtex.balance.balance.CAD).to eq(0.0385)
```

#### View Transactions


```ruby
transactions = @virtex.transactions("BTC").transactions
```

#### View trades

```ruby
recent_trades = @virtex.trades.trades
```

#### View orders

```ruby
recent_orders = @virtex.orders.orders
```

#### Place an order

```ruby
# Place a new order to sell 0.1 BTC/CAD at 1000.00
new_order = @virtex.new_order!('sell', 0.1, 'BTCCAD', 1000.00).order
```

#### Cancel an order

```ruby
@virtex.cancel_order! 543468
```

#### Withdraw to an external wallet

```ruby
withdrawal = @virtex.withdraw!(0.01, 'BTC', '1DWYffTxhXgBtbswMjNViw9nNCvx3Drpvn').result
```

## Testing

If you'd like to contribute code or modify this gem, you can run the test suite with:

```ruby
gem install virtex --dev
bundle exec rspec
```

## Contributing

1. Fork this repo and make changes in your own copy
2. Add a test if applicable and run the existing tests with `rspec` to make sure they pass
3. Commit your changes and push to your fork `git push origin master`
4. Create a new pull request and submit it back to me

## Credits

Thanks to @Skizzk for providing an example of correctly authenticating with Virtex
