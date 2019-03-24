module Heimdallr
  module Auth

    # Utility class for managing scopes.
    #
    # @deprecated This class should not be used and will be removed in a later release. You should instead use arrays.
    #
    class Scopes
      include Enumerable
      include Comparable

      def self.from_string(string)
        string ||= ''
        new.tap do |scope|
          scope.add(*string.split)
        end
      end

      def self.from_array(array)
        new.tap do |scope|
          scope.add(*array)
        end
      end

      def initialize
        @scopes = []
      end

      delegate :each, :empty?, to: :@scopes

      def exists?(scope)
        @scopes.include?(scope.to_s)
      end

      def add(*scopes)
        @scopes.push(*scopes.map(&:to_s))
        @scopes.uniq!
      end

      def all
        @scopes
      end

      def to_s
        @scopes.join(' ')
      end

      def has_scopes?(scopes)
        scopes.all? { |s| exists?(s) }
      end

      def ^(other)
        other.all - all
      end

      def +(other)
        if other.is_a?(Scopes)
          self.class.from_array(all + other.all)
        else
          super(other)
        end
      end

      def <=>(other)
        map(&:to_s).sort <=> other.map(&:to_s).sort
      end

      def &(other)
        other_array = other.present? ? other.all : []
        self.class.from_array(all & other_array)
      end
    end
  end
end
