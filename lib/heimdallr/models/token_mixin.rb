# frozen_string_literal: true

require 'jwt'

module Heimdallr
  module TokenMixin
    extend ActiveSupport::Concern

    included do
      after_find :verify_token_claims
      before_save :not_default, :check_scopes

      attribute :token_errors, :string, array: true, default: []
      attribute :default_token, :boolean, default: false
      attribute :audience, :string
      attribute :subject,  :string

      delegate :algorithm, :secret, :certificate, to: :application, prefix: true
    end

    # Set the scopes for this token.
    #
    # @param [String, Array, Auth::Scopes] value The scopes to set.
    def scopes=(value)
      value = value.split if value.is_a?(String)
      value = value.uniq  if value.is_a?(Array)
      value = value.all   if value.is_a?(Auth::Scopes)
      self[:scopes] = value
    end

    # Checks whether or not this token has specific scopes.
    #
    # @param [Array] values The scopes to check for.
    def has_scopes?(*values)
      values.all? { |scope| scopes.include?(scope) }
    end

    # Removes one or more scopes.
    #
    # @param [Array] values The scope values to remove.
    def remove_scopes(*values)
      values.each do |scope|
        scopes.delete(scope)
      end
    end

    # Checks whether or not this token has errors.
    #
    # @return [Boolean]
    def token_errors?
      token_errors.present?
    end

    def default_token?
      default_token
    end

    # Encodes this token record into a JWT string.
    #
    # @return [String]
    def encode
      raise StandardError, I18n.t(:not_persisted, scope: 'token.errors') unless persisted?
      raise StandardError, I18n.t(:default_token, scope: 'token.errors') if default_token?

      payload = {
        iat: created_at.to_i,
        exp: expires_at.to_i,
        nbf: not_before.to_i,
        iss: application.id,
        aud: audience,
        sub: subject,
        jti: id
      }
      payload.delete_if { |_, value| value.nil? }

      algorithm = application.algorithm
      secret    = application.secret_or_certificate
      JWT.encode(payload, secret, algorithm)
    end

    # Verifies that the token loaded from the database is valid and ready to be used.
    def verify_token_claims
      leeway = Heimdallr.config.expiration_leeway

      token_errors << I18n.t(:revoked, scope: 'token.errors') if revoked?
      token_errors << I18n.t(:not_before, scope: 'token.errors') if not_before.present? && not_before.to_i > (Time.now.utc.to_i - leeway)
      token_errors << I18n.t(:expired, scope: 'token.errors') if expires_at.to_i <= (Time.now.utc.to_i - leeway)
    end

    # Used to hopefully prevent default tokens from being persisted to the database and/or throwing cryptic errors.
    def not_default
      raise StandardError, I18n.t(:default_token, scope: 'token.errors') if default_token?
    end

    # Checks to ensure that the application can issue a token with the requested scopes.
    def check_scopes
      app_scopes     = Auth::Scopes.from_array([*application.scopes])
      token_scopes   = Auth::Scopes.from_array([*scopes])
      invalid_scopes = app_scopes ^ token_scopes

      # Flip out if we have an unauthorized scope
      raise TokenError.new(title: I18n.t(:unable_to_issue, scope: 'token.errors'), detail: "#{I18n.t(:invalid_scopes, scope: 'token.errors')} #{invalid_scopes&.join(', ')}") unless invalid_scopes.empty?

      self.scopes = token_scopes.all
    end
  end
end
