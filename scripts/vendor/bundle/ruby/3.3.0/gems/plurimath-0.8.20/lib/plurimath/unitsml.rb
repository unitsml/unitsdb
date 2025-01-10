# frozen_string_literal: true

require "unitsml"
module Plurimath
  class Unitsml
    attr_accessor :text

    def initialize(text)
      @text = text
      raise Math::ParseError.new(error_message) if text.match?(/\^(([^\s][^*\/,"]*?[a-z]+)|(\([^-\d]+\)|[^\(\d-]+))/)
    end

    def to_formula
      unitsml = ::Unitsml.parse(text)
      formula = unitsml.to_plurimath
      formula.unitsml = true
      formula.input_string = text
      formula.unitsml_xml = unitsml.to_xml
      formula
    end

    def error_message
      <<~MESSAGE
       [plurimath] Invalid formula `#{@text}`.
       [plurimath] The use of a variable as an exponent is not valid.
       [plurimath] If this is a bug, please report the formula at our issue tracker at:
       [plurimath] https://github.com/plurimath/plurimath/issues
      MESSAGE
    end
  end
end
