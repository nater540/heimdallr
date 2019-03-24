Heimdallr.configure do |config|

  # The application model class to use
  config.application_model = JwtApplication

  # The token model class to use
  config.token_model = Token

  # The default JWT algorithm to use
  config.default_algorithm = 'HS512'

  # Token validation period (Default: 30 minutes)
  config.expiration_time = -> { 30.minutes.from_now.utc }

  # The JWT expiration leeway
  config.expiration_leeway = 30.seconds

  # The master encryption key
  config.secret_key = '1c49dd380e6843c6685f18b37e454607'

  # The default scopes to include for requests without a token (Optional)
  config.default_scopes = %w[view]
end
