module GraphQL
  module Helpers

    # Executes a GraphQL query.
    #
    # @param [String] query
    # @param [Hash] variables
    # @param [String] token
    def graphql(query:, variables: {}, token: nil)
      body = {}
      body[:query] = query
      body[:variables] = variables if variables.any?

      headers = {}
      headers[:authorization] = "Bearer #{token}" if token.present?

      post('/graphql', JSON.generate(body), headers)
    end
  end
end

RSpec.configure do |config|
  config.include GraphQL::Helpers
end
