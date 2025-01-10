# frozen_string_literal: true

module Unitsml
  class Parser
    attr_accessor :text

    def initialize(text)
      @regexp = %r{(quantity|name|symbol|multiplier):\s*}
      @text = text&.match(/unitsml\((.*)\)/) ? Regexp.last_match[1] : text
      @orig_text = @text
      @text = @text.gsub("−", "-")
      post_extras
    end

    def parse
      nodes = Parse.new.parse(text)
      formula = Formula.new(
        [
          Transform.new.apply(nodes),
        ],
        explicit_value: @extras_hash,
        root: true,
        orig_text: @orig_text,
        norm_text: text,
      )
      update_units_exponents(formula.value, false)
      formula.value.first.only_instance = true if text.end_with?("-")
      formula
    end

    def update_units_exponents(array, inverse)
      array.each do |object|
        if object.is_a?(Sqrt)
          object = object.value
          object.power_numerator = "0.5"
        end

        case object
        when Unit
          next unless inverse

          exponent = inverse ? "-#{object&.power_numerator || '1'}" : object.power_numerator
          object.power_numerator = exponent&.sub(/^--+/, "")
        when Extender then inverse = !inverse if ["/", "//"].any?(object.symbol)
        when Formula then update_units_exponents(object.value, inverse)
        end
      end
    end

    def post_extras
      return nil unless @regexp.match?(text)

      @extras_hash = {}
      texts_array = text&.split(",")&.map(&:strip)
      @text = texts_array&.shift
      texts_array&.map { |text| parse_extras(text) }
    end

    def parse_extras(text)
      return nil unless @regexp.match?(text)

      key, _, value = text&.partition(":")
      @extras_hash[key&.to_sym] ||= value&.strip
    end
  end
end
