# frozen_string_literal: true

module Unitsml
  class Extender
    attr_accessor :symbol

    def initialize(symbol)
      @symbol = symbol
    end

    def ==(object)
      self.class == object.class &&
        symbol == object&.symbol
    end

    def to_mathml
      Utility.ox_element("mo") << "&#x22c5;"
    end

    def to_latex
      "/"
    end

    def to_asciimath
      symbol
    end

    def to_html
      "&#x22c5;"
    end

    def to_unicode
      symbol == "*" ? "·" : symbol
    end
  end
end
