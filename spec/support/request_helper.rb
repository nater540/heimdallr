module Requests
  module JsonHelpers
    def json
      JSON.parse(last_response.body)
    end
  end
end

RSpec.configure do |config|
  config.include Requests::JsonHelpers
end
