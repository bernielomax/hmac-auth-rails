require 'active_record'

module HmacAuthRails

  class HmacRailtie < Rails::Railtie
    initializer "hmacauthrails.configure_rails_initialization" do |app|
      Mongoid::Document.send :include, HmacAuthenticatable if defined? Mongoid::Document
      ActiveRecord::Base.send :include, HmacAuthenticatable if defined? ActiveRecord::Base
      ActionController::Base.send :include, HmacController
      ActionController::Base.helper_method :hmac_auth
    end
  end

  module HmacAuthenticatable

    extend ActiveSupport::Concern

    included do; end

    module ClassMethods
      def hmac_authenticatable(options = {})
        cattr_accessor :secret_key_field
        cattr_accessor :auth_token_field
        self.secret_key_field = (options[:secret_key_field] || :secret_key).to_s
        self.auth_token_field = (options[:auth_token_field] || :auth_token).to_s
        include HmacAuthRails::HmacAuthenticatable::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods; end

  end

  module HmacController

    def hmac_auth model="User"
      @my_user
      begin
        raise 'Missing X_HMAC_AUTHORIZATION header' unless header_exists? :HTTP_X_HMAC_AUTHORIZATION
        raise 'Missing header HTTP_X_HMAC_CONTENT_MD5 header' unless header_exists? :HTTP_X_HMAC_CONTENT_MD5
        raise 'Missing header HTTP_X_HMAC_CONTENT_TYPE header' unless header_exists? :HTTP_X_HMAC_CONTENT_TYPE
        raise 'Missing header HTTP_X_HMAC_DATE header' unless header_exists? :HTTP_X_HMAC_DATE
        raise 'Could not determine Devise model name' unless model = Object.const_get(model)
        credentials = load_header
        raise "Invalid #{model.auth_token_field}" unless user = model.where("#{model.auth_token_field}" => credentials[:auth_token] ).first
        raise "Invalid #{model.secret_key_field}" unless secret_key = user[model.secret_key_field]
        @my_user = user
        if credentials[:signature] == HmacAuthRails::HmacController.encrypt(secret_key, canonical_string)
          sign_in(user, store: false)
        else
          raise 'Authentication failed.'
        end
      rescue => e
        Rails.logger.error e.to_s
        head :unauthorized
      rescue => e
        Rails.logger.error e
        head :unauthorized
      end
    end

    def self.encrypt(secret_key,string)
      digest = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), secret_key, string)
      if Base64.respond_to?(:strict_encode64)
        Base64.strict_encode64(digest)
      else
        Base64.encode64(digest).gsub(/\n/, '')
      end
    end

    private
    def header_exists? header
      if request.headers.env.has_key? header.to_s
        true
      else
        false
      end
    end

    def canonical_string
      [
          ( request.headers.env["HTTP_X_HMAC_CONTENT_TYPE"] != "null" ? request.headers.env["HTTP_X_HMAC_CONTENT_TYPE"] : "" ),
          ( request.headers.env["HTTP_X_HMAC_CONTENT_MD5"] != "null" ? request.headers.env["HTTP_X_HMAC_CONTENT_MD5"] : "" ),
          request.headers.env["PATH_INFO"],
          request.headers.env["HTTP_X_HMAC_DATE"]
      ].join(",")
    end

    def load_header
      data = request.headers.env["HTTP_X_HMAC_AUTHORIZATION"].gsub(/APIAuth /, '').split(':')
      raise 'Invalid HMAC auth header' if data.size != 2
      raise 'Invalid token inside HMAC auth header' if data.first.empty? or data.first.nil?
      raise 'Invalid secret inside HMAC auth header' if data.last.empty? or data.last.nil?
      return {
          :auth_token => data.first,
          :signature => data.last
      }
    end

  end

end



