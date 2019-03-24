# frozen_string_literal: true

module Heimdallr

  # This class allows you to quickly create a new JWT token.
  #
  # @example
  #   token = Heimdallr::CreateToken.new(
  #       application: application,
  #       scopes: 'unicorn:ride',
  #       expires_at: 1.hour.from_now,
  #       subject: 'Supercalifragilisticexpialidocious'
  #     ).call(encode: false)
  #
  class CreateToken

    # @param [ActiveRecord::Base, Hash] application Either an application object or a hash containing an `:id` & `:key` key.
    # @param [Array] scopes The scopes that this token can access.
    # @param [DateTime] expires_at When this token expires.
    # @param [DateTime] not_before Optional datetime that the token will become active on.
    # @param [String] subject Optional token subject.
    # @param [String] audience Optional token audience.
    # @param [Hash] data Optional data to attach to this token.
    #
    # @raise [ArgumentError] If the `application` hash is missing either the `:id` or `:key` keys.
    def initialize(application:, scopes:, expires_at: nil, not_before: nil, subject: nil, audience: nil, data: {})
      if application.is_a?(Hash)
        raise ArgumentError, 'application input must contain `:id` & `:key` symbol keys.' unless application.key?(:id) && application.key?(:key)

        key = application[:key]
        id  = application[:id]

        # Try to find the application & verify the provided key
        @application = Heimdallr.cache.fetch(Heimdallr.cache_key(id, key)) do
          Heimdallr.app_model.find_by(id: id, key: key)
        end
      else
        @application = application
      end

      @expires_at = expires_at&.utc
      @not_before = not_before&.utc
      @audience   = audience
      @subject    = subject
      @scopes     = scopes
      @data       = data
    end

    # Attempts to create a new token, will raise an ActiveRecord exception upon failure.
    #
    # @return [ActiveRecord::Base]
    #
    # @raise [Heimdallr::TokenError] If the application is not authorized to issue the requested scopes.
    # @raise [ActiveRecord::RecordInvalid]
    def call
      # ip_address = request.remote_ip
      # if @application.ip.present?

      # end

      Heimdallr.token_model.create!(
        application: @application,
        expires_at: @expires_at || Heimdallr.config.expiration_time.call,
        not_before: @not_before,
        audience: @audience,
        subject: @subject,
        scopes: @scopes,
        # ip: ip_address,
        data: @data
      )
    end
  end
end
