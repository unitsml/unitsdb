# frozen_string_literal: true

require_relative "unary_function"

module Plurimath
  module Math
    module Function
      class Ker < UnaryFunction
        def to_omml_without_math_tag(display_style, options:)
          array = []
          array << r_element("ker", rpr_tag: false) unless hide_function_name
          array += Array(omml_value(display_style, options: options))
          array
        end
      end
    end
  end
end