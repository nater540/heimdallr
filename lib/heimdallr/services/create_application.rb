module Heimdallr

  # This class allows you to quickly create a new JWT application.
  #
  # @example
  #  application = Heimdallr::CreateApplication.new(
  #     name: 'My Little Pony',
  #     scopes: %w[pony:create pony:update pony:hug rainbow:generate],
  #     algorithm: 'RS256',
  #     ip: request.remote_ip
  #   ).call
  #
  class CreateApplication

    # @param [String] name The name.
    # @param [String, Array] scopes The scopes that this application can issue tokens for.
    # @param [String] secret It's a secret to everybody.
    # @param [String] algorithm The algorithm to use.
    # @param [String] ip The ip address this application is restricted to.
    def initialize(name:, scopes:, secret: nil, algorithm: Heimdallr.config.default_algorithm, ip: nil)
      @algorithm = algorithm
      @secret = secret
      @scopes = scopes
      @name   = name
      @ip     = ip
    end

    # Attempts to create the application, will raise an ActiveRecord exception upon failure.
    #
    # @return [ActiveRecord::Base]
    # @raise [ActiveRecord::RecordInvalid]
    def call
      Heimdallr.app_model.create!(ip: @ip, name: @name, secret: @secret, scopes: @scopes, algorithm: @algorithm)
    end
  end
end
