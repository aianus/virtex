require 'spec_helper'
require 'virtex'

describe Virtex::Client do

  context "Unauthenticated" do

    before(:each) do
      @virtex = Virtex::Client.new
    end

    it "can retrieve the orderbook" do
      VCR.use_cassette('virtex_unauthenticated_cassette') do
        book = @virtex.orderbook('BTCCAD').orderbook
        bids = book.bids
        asks = book.asks

        best_bid = bids.first
        expect(best_bid[0]).to eq(631.481850000)
        expect(best_bid[1]).to eq(1.367900000)

        best_ask = asks.last
        expect(best_ask[0]).to eq(634.974840000)
        expect(best_ask[1]).to eq(9.727400000)
      end
    end

    it "can retrieve the tradebook" do
      VCR.use_cassette('virtex_unauthenticated_cassette') do
        trades = @virtex.tradebook('BTCCAD').trades
        latest = trades.first

        expect(latest.for_currency).to          eq("BTC")
        expect(latest.price).to                 eq(631.570300000)
        expect(latest.rate).to                  eq(631.570300000)
        expect(latest.amount).to                eq(3.610000000)
        expect(latest.for_currency_amount).to   eq(3.610000000)
        expect(latest.trade_currency).to        eq("CAD")
        expect(latest.date).to                  eq(1407049994.0)
        expect(latest.id).to                    eq(202614)
        expect(latest.trade_currency_amount).to eq(2279.968700000)
      end
    end

    it "can retrieve the ticker" do
      VCR.use_cassette('virtex_unauthenticated_cassette') do
        ticker = @virtex.ticker("BTCCAD").ticker.BTCCAD

        expect(ticker.sell).to   eq(634.91992)
        expect(ticker.volume).to eq(64.912800000)
        expect(ticker.buy).to    eq(632.14943)
        expect(ticker.last).to   eq(632.071010000)
        expect(ticker.high).to   eq(647.999990000)
        expect(ticker.low).to    eq(630.000000000)
      end
    end
  end

  context "Authenticated" do

    before(:each) do
      @virtex = Virtex::Client.new(ENV['VIRTEX_API_KEY'], ENV['VIRTEX_API_SECRET'])
    end

    it "can retrieve the balance" do
      VCR.use_cassette('virtex_authenticated_cassette') do
        expect(@virtex.balance.balance.CAD).to eq(0.0385)
      end
    end

    it "can retrieve transactions" do
      VCR.use_cassette('virtex_authenticated_cassette') do
        transactions = @virtex.transactions("BTC").transactions
        latest       = transactions.first

        expect(latest.currency).to eq("BTC")
        expect(latest.reason).to eq("deposit")
        expect(latest.total).to eq(0.171200000)
        expect(latest.id).to eq(2355387)
        expect(latest.processed).to eq(1407051921)
      end
    end

    it "can place an order" do
      VCR.use_cassette('virtex_authenticated_cassette') do
        new_order    = @virtex.new_order!('sell', 0.1, 'BTCCAD', 1000.00).order

        expect(new_order.status).to eq("open")
        expect(new_order.id).to eq(543468)
      end
    end

    it "can cancel an order" do
      VCR.use_cassette('virtex_authenticated_cassette') do
        r = @virtex.cancel_order! 543468

        expect(r.status).to eq("ok")
      end
    end

    it "can retrieve orders" do
      VCR.use_cassette('virtex_authenticated_cassette') do
        orders = @virtex.orders.orders
        latest = orders.first

        expect(latest.id).to            eq(543468)
        expect(latest.status).to        eq("canceled")
        expect(latest.requested).to     eq(1000)
        expect(latest.created).to       eq(1407052408)
        expect(latest.price).to         eq(1000)
        expect(latest.completed).to     eq(1407052466)
        expect(latest.remaining).to     eq(0.1)
        expect(latest.currency).to      eq("BTC")
        expect(latest.amount).to        eq(0.1)
        expect(latest.mode).to          eq("sell")
        expect(latest.with_currency).to eq("CAD")
      end
    end

    it "can retrieve trades" do
      VCR.use_cassette('virtex_authenticated_cassette') do
        trades = @virtex.trades.trades
        latest = trades.first

        expect(latest.oid).to                   eq(543503)
        expect(latest.id).to                    eq(202617)
        expect(latest.rate).to                  eq(632.071010000)
        expect(latest.date).to                  eq(1407053027.0)
        expect(latest.price).to                 eq(0.00158)
        expect(latest.trade_currency_amount).to eq(0.001000000)
        expect(latest.trade_currency).to        eq("BTC")
        expect(latest.amount).to                eq(0.632000000)
        expect(latest.for_currency_amount).to   eq(0.632000000)
        expect(latest.for_currency).to          eq("CAD")
      end
    end

    it "can withdraw" do
      VCR.use_cassette('virtex_authenticated_cassette') do
        withdrawal = @virtex.withdraw!(0.01, 'BTC', '1DWYffTxhXgBtbswMjNViw9nNCvx3Drpvn').result

        expect(withdrawal.currency).to            eq("BTC")
        expect(withdrawal.reason).to              eq("withdrawal")
        expect(withdrawal.fee).to                 eq(0)
        expect(withdrawal.user).to                eq("aianus")
        expect(withdrawal.wallet).to              eq("1DWYffTxhXgBtbswMjNViw9nNCvx3Drpvn")
        expect(withdrawal.withdrawalfee).to       eq(-0.0005)
        expect(withdrawal.amount).to              eq(-0.01)
        expect(withdrawal.publictransactionid).to eq("1592b009ebeb1bdc2b53a0ffe1a2ae7a56ef4fe011f235a14fa1d7ba085b3c8a")
      end
    end

    context "Error handling" do
      it "throws an error when creating an order you can't pay for" do
        VCR.use_cassette('virtex_authenticated_error_cassette') do
          expect{@virtex.new_order! 'sell', 1.0, 'BTCCAD', 1000.00}.to raise_error(Virtex::Error)
        end
      end
    end

  end

end
