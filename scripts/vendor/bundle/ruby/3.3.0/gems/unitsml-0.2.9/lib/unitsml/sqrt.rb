# frozen_string_literal: true

module Unitsml
  class Sqrt
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def ==(object)
      self.class == object.class &&
        value == object&.value
    end

    def to_asciimath
      value&.to_asciimath
    end

    def to_latex
      value&.to_latex
    end

    def to_mathml
      value&.to_mathml
    end

    def to_html
      value&.to_html
    end

    def to_unicode
      value.to_unicode
    end
  end
end
