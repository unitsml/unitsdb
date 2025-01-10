module Lutaml
  module Model
    class UnknownAdapterTypeError < Error
      def initialize(adapter_name, type_name)
        @adapter_name = adapter_name
        @type_name = type_name

        super()
      end

      def to_s
        "Unknown type: `#{@type_name}` for `#{@adapter_name}` adapter"
      end
    end
  end
end
