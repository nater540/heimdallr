module Mutations
  module Applications
    Create = GraphQL::Relay::Mutation.define do
      # noinspection RubyArgCount
      name 'CreateApplication'
      description 'Creates a new JWT application.'

      input_field :name,      !types.String
      input_field :scopes,    !types[types.String]
      input_field :algorithm, !Types::AlgorithmTypeEnum

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
