# frozen_string_literal: true

module Lutaml
  module Model
    # Comparison of two values for ComparableMapper
    class Comparison
      attr_accessor :original, :updated

      def initialize(original:, updated:)
        @original = original
        @updated = updated
      end
    end
  end
end
