require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to SmugMug via OAuth and retrieve basic user information.
    # Usage:
    #    use OmniAuth::Strategies::SmugMug, 'consumerkey', 'consumersecret'
    #
    class SmugMug < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :authorize_url => 'http://api.smugmug.com/services/oauth/authorize.mg',
          :token_url  => 'http://api.smugmug.com/services/oauth/getAccessToken.mg',
        }
        super(app, :smugmug, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_hash['id'],
          'user_info' => user_info,
          'extra' => { 'user_hash' => user_hash }
        })
      end

      # user info according to schema
      def user_info
        {
          'nickname' => user_hash['NickName'],
          'name' => user_hash['NickName']
        }
      end

      # info as supplied by SmugMug
      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('/services/api/json/1.2.2/?method=smugmug.auth.checkAccessToken').body)['Auth']['User']
      end
    end
  end
end
