module Lutaml
  module Model
    class UnknownTypeError < Error
      def initialize(type_name)
        super("Unknown type '#{type_name}'")
      end
    end
  end
end
