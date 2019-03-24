module Types
  MutationType = GraphQL::ObjectType.define do
    # noinspection RubyArgCount
    name 'Mutation'

    field :createApplication, field: Mutations::Applications::Create.field
    field :createToken, field: Mutations::Tokens::Create.field
  end
end
