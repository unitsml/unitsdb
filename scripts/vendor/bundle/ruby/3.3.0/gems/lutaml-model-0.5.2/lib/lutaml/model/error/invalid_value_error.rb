module Lutaml
  module Model
    class InvalidValueError < Error
      def initialize(attr_name, value, allowed_values)
        @attr_name = attr_name
        @value = value
        @allowed_values = allowed_values

        super()
      end

      def to_s
        "#{@attr_name} is `#{@value}`, must be one of the " \
          "following [#{@allowed_values.join(', ')}]"
      end
    end
  end
end
