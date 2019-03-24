# noinspection ALL
module Types
  ApplicationType = GraphQL::ObjectType.define do
    # noinspection RubyArgCount
    name 'Application'
    description 'JWT Application.'

    field :id,        UuidType
    field :name,      types.String
    field :ip,        types.String
    field :key,       types.String
    field :scopes,    types[types.String]
    field :algorithm, AlgorithmTypeEnum
  end
end
