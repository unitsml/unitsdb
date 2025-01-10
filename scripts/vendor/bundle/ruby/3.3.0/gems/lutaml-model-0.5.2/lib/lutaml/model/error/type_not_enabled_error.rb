module Lutaml
  module Model
    class TypeNotEnabledError < Error
      def initialize(type_name, value)
        super("#{type_name} type is not enabled. Value: #{value}")
      end
    end
  end
end
