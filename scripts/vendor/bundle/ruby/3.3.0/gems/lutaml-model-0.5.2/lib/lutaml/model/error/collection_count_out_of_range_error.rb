module Lutaml
  module Model
    class CollectionCountOutOfRangeError < Error
      def initialize(attr_name, value, range)
        @attr_name = attr_name
        @value = value
        @range = range

        super()
      end

      def to_s
        "#{@attr_name} count is #{@value.size}, must be #{range_to_string}"
      end

      private

      def range_to_string
        if @range.end.nil?
          "at least #{@range.begin}"
        elsif @range.begin == @range.end
          "exactly #{@range.begin}"
        else
          "between #{@range.begin} and #{@range.end}"
        end
      end
    end
  end
end
