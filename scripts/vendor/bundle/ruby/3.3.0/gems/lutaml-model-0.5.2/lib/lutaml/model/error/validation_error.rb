module Lutaml
  module Model
    class ValidationError < Error
      attr_reader :errors

      def initialize(errors)
        @errors = errors
        super(errors.join(", "))
      end

      def include?(error_class)
        errors.any?(error_class)
      end

      def error_messages
        errors.map(&:message)
      end
    end
  end
end
