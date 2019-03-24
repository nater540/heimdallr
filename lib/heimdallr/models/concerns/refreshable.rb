module Heimdallr
  module Models
    module Refreshable

      # Refreshes this token by a given amount of time & persists to the database.
      #
      # @param [Integer] amount
      def refresh!(amount: 30.minutes)
        refresh(amount: amount)
        save!
      end

      # Refreshes this token by a given amount of time but does NOT persist to the database.
      #
      # @param [Integer] amount
      def refresh(amount: 30.minutes)
        self[:expires_at] = expires_at + amount
      end
    end
  end
end
