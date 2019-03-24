module Types
  QueryType = GraphQL::ObjectType.define do
    # noinspection RubyArgCount
    name 'Query'

    field :token, TokenType do
      resolve ->(_, _, ctx) do
        ctx[:token]
      end
    end
  end
end
