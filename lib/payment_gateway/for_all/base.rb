require 'http'
require 'pry-rails'
module PaymentGateway
  module ForAll
    class Base
      class MerchantKeyNotFound < StandardError; end
      class GatewayError      < StandardError; end

      API_URL = retrieve_url

      def initialize
        raise MerchantKeyNotFound if PaymentGateway::ForAll.configuration.merchant_key.blank?
      end

      protected

      def request(method, url, options={ body: {}, params: {} })
        options[:body].merge!({'merchantKey': PaymentGateway::ForAll.configuration.merchant_key})
        response = HTTP.
            headers('Content-Type' => 'application/json').
            send(method, url, json: options[:body].with_indifferent_access)
        if response.status.eql?(200)
          response.parse.with_indifferent_access
        else
          error_message = "#{response.status} - #{response.parse['errors'] || response.parse['message']}"
          raise GatewayError, error_message
        end
      end

      def access_key
        access_key = PaymentGateway::ForAll.configuration.access_key
        access_key.blank? ? Vault.new.request_key : access_key
      end

      def retrieve_url
        'https://gateway.homolog-interna.4all.com' if @environment == :development
        'https://gateway.api.4all.com'             if @environment == :production
      end
    end
  end
end