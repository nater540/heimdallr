module Mutations
  # noinspection ALL
  module Applications
    Create = GraphQL::Relay::Mutation.define do
      # noinspection RubyArgCount
      name 'CreateApplication'
      description 'Creates a new JWT application.'

      # noinspection RubyResolve
      input_field :name,      !types.String
      # noinspection RubyResolve
      input_field :scopes,    !types[types.String]
      # noinspection RubyResolve
      input_field :algorithm, !Types::AlgorithmTypeEnum

      # noinspection RubyResolve
      return_field :application, Types::ApplicationType

      resolve ->(_obj, args, _ctx) {
        application = Heimdallr::CreateApplication.new(
          name: args[:name],
          scopes: args[:scopes],
          algorithm: args[:algorithm]
        ).call

        { application: application }
      }
    end
  end
end
