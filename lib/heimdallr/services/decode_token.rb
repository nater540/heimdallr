# frozen_string_literal: true

require 'jwt'
require 'openssl'

module Heimdallr

  # This class is used decode previously issued JWT tokens.
  #
  # Tokens are required to include at least the `iss` (Issuer) and `jti` (JWT ID) claims which are used to look up the application & token from the database.
  #
  # @example
  #   token = Heimdallr::DecodeToken.new('JWT-ENCODED-STRING-GOES-HERE', leeway: 30.seconds).call
  #
  class DecodeToken

    # Constructor
    #
    # @param [String] jwt The JWT string to decode.
    # @param [Integer] leeway The leeway value to use for expiration & not-before claim verification.
    def initialize(jwt, leeway: Heimdallr.config.expiration_leeway)
      @leeway = leeway
      @jwt    = jwt
    end

    # Attempts to decode the JWT string, will raise exceptions upon critical errors.
    #
    # @return [ActiveRecord::Base, nil] Returns nil if no JWT was provided, otherwise returns a Token object.
    # @raise [Heimdallr::TokenError] If a critical error occurred that cannot be recovered from.
    def call
      return nil if @jwt.blank?

      # When upgrading ~> JWT 2.1.0 you *MUST* pass `true` for verify, otherwise the signature will not be decoded :|
      decoder = JWT::Decode.new(@jwt, true)
      header, payload, signature, signing_input = decoder.decode_segments

      # Grab the issuer & token ID so we can check for blacklisted tokens
      issuer = payload.fetch('iss')
      jwt_id = payload.fetch('jti')

      db_token = Heimdallr
                   .token_model
                   .where(id: jwt_id, application_id: issuer)
                   .limit(1)
                   .preload(:application)
                   .take!

      # Grab the algorithm & secret values to use for verification
      algorithm = db_token.application.algorithm
      secret    = db_token.application.secret_or_certificate

      # Verify the JWT signature to help ensure the token has not been tampered with
      JWT::Signature.verify(algorithm, secret, signing_input, signature)
      raise TokenError.new(title: I18n.t(:invalid, scope: 'token.errors'), detail: I18n.t(:incorrect_segments, scope: 'jwt.errors')) unless header && payload

      # Ensure that the expiration claim matches what we have stored in the database
      expiration_claim = payload.fetch('exp')
      if expiration_claim.to_i != db_token.expires_at.to_i

        # We want to be semi-vague here since the token was tampered with and we do not know who the guilty party is
        raise TokenError.new(title: I18n.t(:invalid, scope: 'token.errors'), detail: I18n.t(:generic, scope: 'token.errors'))
      end

      # Ensure that the not_before claim matches what we have stored in the database
      not_before_claim = payload.fetch('nbf', nil)
      if not_before_claim.to_i != db_token.not_before.to_i

        # We want to be semi-vague here since the token was tampered with and we do not know who the guilty party is
        raise TokenError.new(title: I18n.t(:invalid, scope: 'token.errors'), detail: I18n.t(:generic, scope: 'token.errors'))
      end

      db_token.audience = payload.fetch('aud', nil)
      db_token.subject  = payload.fetch('sub', nil)
      db_token

    rescue KeyError, ActiveRecord::RecordNotFound, JWT::VerificationError
      raise TokenError.new(title: I18n.t(:invalid, scope: 'token.errors'), detail: I18n.t(:generic, scope: 'token.errors'))
    end
  end
end
