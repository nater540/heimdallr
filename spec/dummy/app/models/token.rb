class Token < ApplicationRecord
  include Heimdallr::TokenMixin

  # Support token refreshing
  include Heimdallr::Models::Refreshable

  # Support token revoking
  include Heimdallr::Models::Revocable

  belongs_to :application, class_name: 'JwtApplication'
end
