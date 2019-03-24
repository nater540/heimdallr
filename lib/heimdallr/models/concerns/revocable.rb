module Heimdallr
  module Models
    module Revocable

      # Revokes this token & persists to the database.
      def revoke!
        revoke
        save!
      end

      # Revokes this token but does NOT persist to the database.
      def revoke
        self[:revoked_at] = Time.now.utc
      end

      # Checks whether or not this token has been revoked.
      #
      # @return [Boolean]
      def revoked?
        self[:revoked_at].present?
      end
    end
  end
end
