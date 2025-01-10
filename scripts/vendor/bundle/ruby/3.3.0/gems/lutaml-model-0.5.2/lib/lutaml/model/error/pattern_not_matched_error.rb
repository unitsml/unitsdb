module Lutaml
  module Model
    class PatternNotMatchedError < Error
      def initialize(attr_name, pattern, value)
        @attr_name = attr_name
        @pattern = pattern
        @value = value

        super()
      end

      def to_s
        "#{@attr_name}: \"#{@value}\" does not match #{@pattern.inspect}"
      end
    end
  end
end
