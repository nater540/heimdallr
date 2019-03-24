# frozen_string_literal: true

module Heimdallr
  module Authenticable
    BEARER_TOKEN_REGEX = /^[B|b]earer\s([a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]*)$/

    # Authorizes the current request.
    # Many things may happen during this call:
    #  - If there is NOT a token:
    #   - Default scopes have NOT been configured: An Unauthorized error will be rendered.
    #   - Default scopes have been configured: A new non-persisted token will be created.
    #
    #  - If there is a token:
    #   - If the token is expired, an error will be rendered.
    #   - If the token has been revoked, an error will be rendered.
    #
    def heimdallr_authorize!
      heimdallr_render_error unless valid_heimdallr_token?
    rescue Heimdallr::TokenError => error
      heimdallr_render_error(error)
    end

    # Gets the current JWT token.
    def heimdallr_token
      @token ||= authenticate_request
    end

    # Checks to see if the current request has a token & is valid.
    #
    # @return [Boolean]
    def valid_heimdallr_token?
      heimdallr_token && !heimdallr_token.token_errors?
    end

    private

    # Renders a token error as JSON.
    #
    # @param [TokenError] error
    def heimdallr_render_error(error = nil)
      if error.blank?
        error = heimdallr_token&.token_errors || [{
                                                    source: { pointer: '/request/headers/authorization' },
                                                    title: I18n.t(:unauthorized, scope: :errors),
                                                    detail: I18n.t(:missing_auth_header, scope: :errors)
                                                  }]
      end

      render json: { errors: [*error] }, status: 401
    end

    # Attempts to authenticate the current request.
    #
    # @return [Token, nil]
    def authenticate_request
      header = request.authorization
      return create_default_token if invalid_auth_header?(header)

      # Extract the token from the header
      token = BEARER_TOKEN_REGEX.match(header)[1]
      DecodeToken.new(token).call
    end

    # Checks whether the given header matches the correct regex.
    #
    # @return [Boolean]
    def invalid_auth_header?(header)
      header !~ BEARER_TOKEN_REGEX
    end

    # Creates a default token if `default_scopes` are set in the initializer.
    #
    # @return [Token, nil] If
    def create_default_token
      return nil if Heimdallr.config.default_scopes.blank?
      Token.new(scopes: [*Heimdallr.config.default_scopes], default_token: true).freeze
    end
  end
end
