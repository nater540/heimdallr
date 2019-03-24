module Types
  GrantTypeEnum = GraphQL::EnumType.define do
    # noinspection RubyArgCount
    name 'GrantType'
    description 'The JWT authorization grant type to use.'

    value('SECRET', 'Application secret grant type.', value: :secret)
  end
end
