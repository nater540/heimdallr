module Mutations
  # noinspection ALL
  module Tokens
    Create = GraphQL::Relay::Mutation.define do
      # noinspection RubyArgCount
      name 'CreateToken'

      ApplicationInputType = GraphQL::InputObjectType.define do
        # noinspection RubyArgCount
        name 'ApplicationInput'

        argument :id,  !Types::UuidType
        argument :key, !types.String
      end

      # noinspection RubyResolve
      input_field :application, !ApplicationInputType
      # noinspection RubyResolve
      input_field :audience,  types.String
      # noinspection RubyResolve
      input_field :subject,   types.String
      # noinspection RubyResolve
      input_field :scopes,    !types[types.String]

      # noinspection RubyResolve
      return_field :token, Types::TokenType

      resolve ->(_, args, _) do
        begin
          token = Heimdallr::CreateToken.new(
            application: args[:application].to_h,
            scopes: args[:scopes],
            subject: args[:subject],
            audience: args[:audience],
            expires_at: Heimdallr.config.expiration_time.call
          ).call

          { token: token }
        rescue ArgumentError, Heimdallr::TokenError => error
          GraphQL::ExecutionError.new(error.message)
        end
      end
    end
  end
end
