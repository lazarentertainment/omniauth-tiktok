# frozen_string_literal: true


require 'oauth2'
require 'omniauth-oauth2'
require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Tiktok < OmniAuth::Strategies::OAuth2
      class AccessToken < ::OAuth2::AccessToken
      end

      class NoAuthorizationCodeError < StandardError; end
      DEFAULT_SCOPE = 'user.info.basic,user.info.profile'
      USER_INFO_URL = 'https://open.tiktokapis.com/v2/user/info/'

      option :name, 'tiktok'
      args %i[client_key client_secret]

      option :client_options, {
        site: 'https://www.tiktok.com',
        authorize_url: 'https://www.tiktok.com/v2/auth/authorize/',
        token_url: 'https://open.tiktokapis.com/v2/oauth/token/',
        access_token_class: OmniAuth::Strategies::Tiktok::AccessToken
      }

      uid { raw_info.fetch('open_id') }

      info do
        hash = {
          name: raw_info.fetch('display_name'),
          image: raw_info.fetch('avatar_url_100')
        }
        if request.params.fetch('scopes').include?('user.info.profile')
          hash.merge!(
            nickname: raw_info.fetch('username'),
            description: raw_info.fetch('bio_description'),
            email: "#{raw_info.fetch('username')}@tiktok.stageten.tv",
            urls: {
              'TikTok' => raw_info.fetch('profile_web_link'),
              'TikTok Deep Link' => raw_info.fetch('profile_deep_link')
            }
          )
        end
        hash
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      credentials do
        hash = {}
        hash['token'] = access_token.token
        hash['refresh_token'] = access_token.refresh_token if access_token.expires? && access_token.refresh_token
        hash['expires_at'] = access_token.expires_at if access_token.expires?
        hash['expires'] = access_token.expires?
        refresh_token_expires_at = Time.now.to_i + access_token.params['refresh_expires_in'].to_i
        hash['refresh_token_expires_at'] = refresh_token_expires_at
        hash
      end

      def raw_info
      ::Rails.logger.debug("raw_info")
        @raw_info ||= user_info
      end

      def callback_url
        options[:callback_url] || (full_host + script_name + callback_path)
      end

      def authorize_params
        super.tap do |params|
          params[:scope] ||= DEFAULT_SCOPE
          params[:response_type] = 'code'
          params[:client_key] = options.client_key
        end
      end

      def token_params
        super.tap do |params|
          params[:client_key] = options.client_key
          params[:client_secret] = options.client_secret
        end
      end

      private

      def user_info
        @user_info = begin
          fields = %w[open_id union_id avatar_url avatar_url_100 display_name]
          scopes = request.params.fetch('scopes')
          if scopes.include?('user.info.profile')
            fields.push('profile_web_link', 'profile_deep_link', 'bio_description', 'is_verified', 'username')
          end
          response = access_token
                     .get(
                       USER_INFO_URL,
                       params: {
                         fields: fields.join(',')
                       }
                     )
                     .parsed
          response.fetch('data').fetch('user').to_hash
        end
        @user_info
      end
    end
  end
end
