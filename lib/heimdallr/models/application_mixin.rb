# frozen_string_literal: true

module Heimdallr
  module ApplicationMixin
    extend ActiveSupport::Concern

    included do
      before_validation :generate_key, :generate_secret, on: :create
      # noinspection RubyResolve
      before_save :check_scopes, :clear_cache

      validates :scopes, :key, :secret, presence: true
    end

    # Set the scopes for this application.
    #
    # @param [String, Array, Auth::Scopes] value The scopes to set.
    def scopes=(value)
      value = value.split if value.is_a?(String)
      value = value.uniq  if value.is_a?(Array)
      value = value.all   if value.is_a?(Auth::Scopes)
      self[:scopes] = value
    end

    # Regenerates the secret key.
    #
    # **Warning:**
    # Calling this method will effectively revoke all tokens owned by this application!
    def regenerate_secret!
      regenerate_secret
      save!
    end

    # Regenerates the secret key.
    #
    # **Warning:**
    # Calling this method will effectively revoke all tokens owned by this application!
    def regenerate_secret
      self.secret = SecureRandom.hex(16).to_s
    end

    # Regenerates the RSA private key.
    #
    # **Warning:**
    # Calling this method will effectively revoke all tokens owned by this application!
    #
    # @raise [StandardError] If this application does not use RSA for cryptographic signing.
    def regenerate_certificate!
      regenerate_certificate
      save!
    end

    # Regenerates the RSA private key.
    #
    # **Warning:**
    # Calling this method will effectively revoke all tokens owned by this application!
    #
    # @raise [StandardError] If this application does not use RSA for cryptographic signing.
    def regenerate_certificate
      raise StandardError, I18n.t(:does_not_use_rsa, scope: 'application.errors') unless %w[RS256 RS384 RS512].include?(algorithm)
      self.certificate = OpenSSL::PKey::RSA.generate(2048).to_s
    end

    # Gets the RSA certificate for this application.
    #
    # @return [OpenSSL::PKey::RSA]
    def rsa
      raise StandardError, I18n.t(:does_not_use_rsa, scope: 'application.errors') unless %w[RS256 RS384 RS512].include?(algorithm)
      OpenSSL::PKey::RSA.new(certificate)
    end

    # Getter for returning the secret or a OpenSSL certificate.
    #
    # @return [String, OpenSSL::PKey]
    def secret_or_certificate
      if %w[RS256 RS384 RS512].include?(algorithm)
        return OpenSSL::PKey::RSA.new(certificate)
      end

      secret
    end

    private

    # Generates a new application key if one does not already exist.
    def generate_key
      self.key = excessively_random_string if key.blank?
    end

    # Generates a secret value and if necessary also a RSA certificate.
    def generate_secret
      self.certificate = OpenSSL::PKey::RSA.generate(2048).to_s if %w[RS256 RS384 RS512].include?(algorithm)
      self.secret = SecureRandom.hex(16).to_s
    end

    # Excessive random string generator.
    #
    # @return [String]
    def excessively_random_string
      # noinspection RubyResolve
      Digest::SHA256.hexdigest([
        SecureRandom.uuid,
        SecureRandom.uuid,
        rand(9000)
      ].join).to_s
    end

    # Checks the application scopes and removes duplicates.
    def check_scopes
      scopes = Auth::Scopes.from_array([*self.scopes])
      self.scopes = scopes.all
    end

    def cache_key
      "#{self.id}:#{self.key}"
    end

    # Clears any cached values for this application.
    def clear_cache
      Heimdallr.cache.delete(cache_key)
    end
  end
end
