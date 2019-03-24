# frozen_string_literal: true

require 'heimdallr/engine'
require 'heimdallr/config'

# Namespace for the Heimdallr gem.
module Heimdallr

  # Error class that is raised when a critical token error occurs.
  class TokenError < StandardError
    attr_accessor :title, :status, :links
    def initialize(title:, detail:, status: 403, links: {})
      @title  = title
      @status = status
      @links  = links
      super(detail)
    end
  end

  LIBRARY_PATH = File.join(File.dirname(__FILE__), 'heimdallr')
  autoload :Authenticable, File.join(LIBRARY_PATH, 'authenticable')

  module Auth
    AUTH_PATH = File.join(LIBRARY_PATH, 'auth')
    autoload :Scopes, File.join(AUTH_PATH, 'scopes')
  end

  # Autoload all of the model mixins & concerns
  MODELS_PATH = File.join(LIBRARY_PATH, 'models')
  autoload :ApplicationMixin, File.join(MODELS_PATH, 'application_mixin')
  autoload :TokenMixin,       File.join(MODELS_PATH, 'token_mixin')

  module Models
    autoload :Refreshable, File.join(MODELS_PATH, 'concerns', 'refreshable')
    autoload :Revocable,   File.join(MODELS_PATH, 'concerns', 'revocable')
  end

  # Autoload all of the service classes
  SERVICES_PATH = File.join(LIBRARY_PATH, 'services')
  autoload :CreateApplication, File.join(SERVICES_PATH, 'create_application')
  autoload :CreateToken,       File.join(SERVICES_PATH, 'create_token')
  autoload :DecodeToken,       File.join(SERVICES_PATH, 'decode_token')

  class << self

    # @return [ActiveSupport::Cache::Store]
    def cache
      @cache ||= case Heimdallr.config.cache.backend
                   when :redis
                     ActiveSupport::Cache::RedisCacheStore.new(Heimdallr.config.cache.redis)
                   else
                     ActiveSupport::Cache::MemoryStore.new
                 end
    end

    # Simple function for generating cache keys.
    #
    # @param [Array] ids
    # @return [String]
    def cache_key(*ids)
      ids.join(':')
    end

    # Short-hand helper function to get the application model class.
    #
    # @return [ActiveRecord::Base]
    def app_model
      Heimdallr.config.application_model
    end

    # Short-hand helper function to get the token model class.
    #
    # @return [ActiveRecord::Base]
    def token_model
      Heimdallr.config.token_model
    end
  end
end
