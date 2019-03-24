# noinspection ALL
module Types
  TimeType = GraphQL::ScalarType.define do
    # noinspection RubyArgCount
    name 'Time'
    description 'This thing all things devours, birds, beasts, trees, flowers; Gnaws iron, bites steel; Grinds hard stones to meal; Slays king, ruins town, and beats high mountain down.'

    coerce_input ->(value, _ctx) { Time.at(Float(value)).utc }
    coerce_result ->(value, _ctx) { value.to_f }
    # noinspection RubyResolve
    default_scalar true
  end
end
