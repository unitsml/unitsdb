# frozen_string_literal: true

module Unitsml
  class Dimension
    attr_accessor :dimension_name, :power_numerator

    def initialize(dimension_name, power_numerator = nil)
      @dimension_name = dimension_name
      @power_numerator = power_numerator
    end

    def ==(object)
      self.class == object.class &&
        dimension_name == object&.dimension_name &&
        power_numerator == object&.power_numerator
    end

    def dim_hash
      Unitsdb.parsable_dimensions[dimension_name]
    end

    def dim_symbols
      dim_hash&.values&.last&.values&.first["dim_symbols"].first
    end

    def to_mathml
      value = dim_symbols["mathml"]
      value = Ox.parse(value)
      if power_numerator
        msup = Utility.ox_element("msup")
        msup << (Utility.ox_element("mrow") << value)
        msup << (
          Utility.ox_element("mrow") << (
            Utility.ox_element("mn") << power_numerator
          )
        )
        value = msup
      end
      value
    end

    def to_latex
      value = dim_symbols["latex"]
      if power_numerator
        value = "#{value}^#{power_numerator}"
      end
      value
    end

    def to_asciimath
      value = dim_symbols["ascii"]
      value = "#{value}^#{power_numerator}" if power_numerator
      value
    end

    def to_html
      value = dim_symbols["html"]
      value = "#{value}<sup>#{power_numerator}</sup>" if power_numerator
      value
    end

    def to_unicode
      value = dim_symbols["unicode"]
      value = "#{value}^#{power_numerator}" if power_numerator
      value
    end

    def generate_id
      "#{dimension_name.split('_').last}#{power_numerator}"
    end

    def to_xml
      fields = dim_hash[:fields]
      symbol = fields.values.first["symbol"]
      power_numerator_value = power_numerator || 1
      attributes = { symbol: symbol, powerNumerator: power_numerator_value }
      element_name = modelize(fields.keys.first.capitalize)
      Utility.ox_element(element_name, attributes: attributes)
    end

    def modelize(value)
      value&.split("_")&.map(&:capitalize)&.join
    end
  end
end
