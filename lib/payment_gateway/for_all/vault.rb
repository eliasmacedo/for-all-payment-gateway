module PaymentGateway
  module ForAll
    class Vault < Base

      def request_key
        PaymentGateway::ForAll.configure do |configure|
          configure.access_key = request(:post, endpoint)[:accessKey]
        end
      end

      private

      def endpoint
        api_url + '/requestVaultKey'
      end
    end
  end
end