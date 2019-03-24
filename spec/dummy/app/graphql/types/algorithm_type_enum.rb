module Types
  AlgorithmTypeEnum = GraphQL::EnumType.define do
    # noinspection RubyArgCount
    name 'AlgorithmType'
    description 'The JWT algorithm to use.'

    value('HS256', 'HMAC using SHA-256 hash algorithm.')
    value('HS384', 'HMAC using SHA-384 hash algorithm.')
    value('HS512', 'HMAC using SHA-512 hash algorithm.')
    value('RS256', 'RSA using SHA-256 hash algorithm.')
    value('RS384', 'RSA using SHA-384 hash algorithm.')
    value('RS512', 'RSA using SHA-512 hash algorithm.')
  end
end
