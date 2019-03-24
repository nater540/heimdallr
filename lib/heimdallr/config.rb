require 'dry-configurable'

module Heimdallr
  extend Dry::Configurable

  setting :application_model

  setting :token_model

  setting :default_algorithm, 'HS512'

  setting :expiration_time, -> { 30.minutes.from_now.utc }

  setting :expiration_leeway, 30.seconds

  setting :secret_key

  setting :default_scopes, []

  setting :cache do
    setting :backend, :memory

    setting :redis do
      setting :url
      setting :namespace
      setting :expires_in, 15.minutes
    end
  end
end
