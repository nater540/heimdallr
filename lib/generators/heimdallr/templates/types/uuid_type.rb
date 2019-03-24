# noinspection ALL
module Types
  UuidType = GraphQL::ScalarType.define do
    # noinspection RubyArgCount
    name 'Uuid'
    description 'A universally unique identifier (UUID) is a 128-bit number used to identify information in computer systems.'

    coerce_input ->(value, _ctx) { value =~ /[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}/ ? value : nil }
    coerce_result ->(value, _ctx) { value.to_s }
    # noinspection RubyResolve
    default_scalar true
  end
end
