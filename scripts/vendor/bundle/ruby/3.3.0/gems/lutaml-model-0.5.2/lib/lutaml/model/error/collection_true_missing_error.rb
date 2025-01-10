module Lutaml
  module Model
    class CollectionTrueMissingError < Error
      def initialize(attr_name, caller_class)
        @attr_name = attr_name
        @caller = caller_class

        super()
      end

      def to_s
        "May be `collection: true` is missing for `#{@attr_name}` in #{@caller}"
      end
    end
  end
end
