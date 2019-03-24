module Types
  TokenType = GraphQL::ObjectType.define do
    # noinspection RubyArgCount
    name 'Token'
    description 'JWT Token.'

    field :id,      UuidType
    field :ip,      types.String
    field :scopes,  types[types.String]
    field :application, ApplicationType

    field :jwt, types.String do
      resolve ->(obj, _, _) { obj.encode }
    end

    field :createdAt, DateTimeType do
      resolve ->(obj, _, _) { obj.created_at }
    end

    field :expiresAt, DateTimeType do
      resolve ->(obj, _, _) { obj.expires_at }
    end

    field :revokedAt, DateTimeType do
      resolve ->(obj, _, _) { obj.revoked_at }
    end

    field :notBefore, DateTimeType do
      resolve ->(obj, _, _) { obj.not_before }
    end
  end
end
