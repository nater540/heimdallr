module Types
  DateTimeType = GraphQL::ScalarType.define do
    # noinspection RubyArgCount
    name 'DateTime'
    description 'An ISO-8601 encoded UTC date string.'

    coerce_input ->(value, _ctx) { Time.iso8601(value).gmtime }
    coerce_result ->(value, _ctx) { value.to_s }
    default_scalar true
  end
end
