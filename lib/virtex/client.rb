require 'httparty'
require 'hashie'

module Virtex
  class Client
    include HTTParty

    # From 0.000000001 to 10,000,000
    VIRTEX_SIGNIFICANT_DIGITS = 16
    BASE_URI = 'https://cavirtex.com/api2'

    def initialize(api_key=nil, api_secret=nil, options={})
      @api_key = api_key
      @api_secret = api_secret

      # defaults
      options[:base_uri] ||= BASE_URI
      @base_uri = options[:base_uri]
      options.each do |k,v|
        self.class.send k, v
      end
    end

    # Unauthenticated

    def orderbook currencypair
      do_request '/orderbook.json', { get: { 'currencypair' => currencypair } }
    end

    def tradebook currencypair, opts = {}
      params = {
        'currencypair' => currencypair
      }.merge(opts)
      do_request '/trades.json', { get: params }
    end

    def ticker currencypair
      do_request '/ticker.json', { get: { 'currencypair' => currencypair } }
    end

    # Authenticated

    def balance
      do_request '/user/balance.json'
    end

    def orders opts = {}
      do_request '/user/orders.json', { post: opts }
    end

    def trades opts = {}
      do_request '/user/trades.json', { post: opts }
    end

    def transactions currency, opts = {}
      params = {
        'currency' => currency
      }.merge(opts)

      do_request '/user/transactions.json', { post: params }
    end

    def new_order! mode, amount, currencypair, price, opts = {}
      params = {
        'mode' => mode,
        'amount' => amount,
        'price' => price,
        'currencypair' => currencypair
      }.merge(opts)

      do_request '/user/order.json', { post: params }
    end

    def cancel_order! id
      do_request '/user/order_cancel.json', { post: { 'id' => id } }
    end

    def withdraw! amount, currency, address
      params = {
        'amount'   => amount,
        'currency' => currency,
        'address'  => address
      }
      do_request '/user/withdraw.json', { post: params }
    end

  protected

    def generate_api_signature(endpoint, nonce, params)
      # Alphabetically sorted post parameters for signature
      data = ""
      params.keys.sort.each do |k|
        data += params[k].to_s
      end

      digest = OpenSSL::Digest.new('sha256')
      OpenSSL::HMAC.hexdigest(digest, @api_secret, nonce.to_s + @api_key + '/api2' + endpoint + data)
    end

    def do_request(path, options={})
      options[:get] ||= {}
      options[:post] ||= {}

      path = "#{path}?#{URI.encode_www_form(options[:get])}" if !options[:get].empty?

      nonce = options[:nonce] || (Time.now.to_f * 1e6).to_i

      if (@api_key && @api_secret)
        auth_params = {
          token: @api_key,
          nonce: nonce,
          signature: generate_api_signature(path, nonce, options[:post])
        }
      else
        auth_params = {}
      end

      r = self.class.post(path, body: options[:post].merge(auth_params))

      case r.code
      when 504
        raise TimeoutError, "Gateway timeout, please try again later"
      when 500..600
        raise ServerError, "Server error: (#{r.code})"
      when 401
        raise UnauthorizedError
      when 404
        raise NotFoundError
      end

#      Virtex API is incorrectly returning text/html so ignore this for now
#      if !r.headers['content-type'].downcase.include? 'json'
#        raise Error, "Unrecognized content type #{r.headers['content-type']}"
#      end

      hash = Hashie::Mash.new(JSON.parse(r.body))

      if hash.status == "error"
        raise Error, hash.message
      end

      hash
    end
  end
end
