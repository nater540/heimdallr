class JwtApplication < ApplicationRecord
  include Heimdallr::ApplicationMixin
  has_many :tokens
end
