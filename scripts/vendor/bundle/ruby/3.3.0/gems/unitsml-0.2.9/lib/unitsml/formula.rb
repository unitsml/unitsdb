# frozen_string_literal: true

require "plurimath"
require_relative "utility"
module Unitsml
  class Formula
    attr_accessor :value, :explicit_value, :root

    def initialize(value = [],
                   explicit_value: nil,
                   root: false,
                   orig_text: nil,
                   norm_text: nil)
      @value = value
      @explicit_value = explicit_value
      @root = root
      @orig_text = orig_text
      @norm_text = norm_text
    end

    def ==(object)
      self.class == object.class &&
        value == object&.value &&
        explicit_value == object&.explicit_value &&
        root == object.root
    end

    def to_mathml
      if root
        attributes = { xmlns: "http://www.w3.org/1998/Math/MathML", display: "block" }
        math = Utility.ox_element("math", attributes: attributes)
        Ox.dump(
          Utility.update_nodes(
            math,
            value.map(&:to_mathml).flatten,
          ),
        ).gsub(/&amp;(.*?)(?=<\/)/, '&\1')
      else
        value.map(&:to_mathml)
      end
    end

    def to_latex
      value.map(&:to_latex).join
    end

    def to_asciimath
      value.map(&:to_asciimath).join
    end

    def to_html
      value.map(&:to_html).join
    end

    def to_unicode
      value.map(&:to_unicode).join
    end

    def to_xml
      dimensions_array = extract_dimensions(value)
      if (dimensions_array).any?
        dimensions(sort_dims(dimensions_array))
      elsif @orig_text.match(/-$/)
        prefixes
      else
        units
      end
    end

    def to_plurimath
      return Plurimath::Math.parse(to_asciimath, :asciimath) if @orig_text.match?(/-$/)

      Plurimath::Math.parse(to_mathml, :mathml)
    end

    private

    def extract_dimensions(formula)
      dimensions = []

      formula.each do |term|
        if term.is_a?(Dimension)
          dimensions << term
        elsif term.is_a?(Sqrt) && term.value.is_a?(Dimension)
          sqrt_term = term.value.dup
          sqrt_term.power_numerator = "0.5"
          dimensions << sqrt_term
        elsif term.is_a?(Formula)
          dimensions.concat(extract_dimensions(term.value))
        end
      end

      dimensions
    end

    def extract_units(formula)
      units_arr = []

      formula.each do |term|
        case term
        when Unit
          units_arr << term.dup
        when Formula
          units_arr.concat(extract_units(term.value.dup))
        when Sqrt
          next unless term.value.is_a?(Unit)

          units_arr << term.value
        end
      end

      units_arr
    end

    def units
      all_units = extract_units(value)
      norm_text = Utility.postprocess_normtext(all_units)
      dims = Utility.units2dimensions(extract_units(value))
      dimension, dimension_component = unique_dimensions(dims, norm_text)
      [
        Utility.unit(all_units, self, dims, norm_text, explicit_value&.dig(:name)),
        Utility.prefixes(all_units),
        dimension,
        dimension_component,
        Utility.quantity(norm_text, explicit_value&.dig(:quantity)),
      ].join
    end

    def unique_dimensions(dims, norm_text)
      [
        Utility.dimension(norm_text),
        Utility.dimension_components(dims),
      ].uniq
    end

    def dimensions(dims)
      dim_id = dims.map(&:generate_id).join
      attributes = { xmlns: Utility::UNITSML_NS, "xml:id": "D_#{dim_id}" }
      Ox.dump(
        Utility.update_nodes(
          Utility.ox_element("Dimension", attributes: attributes),
          dims.map(&:to_xml),
        ),
      )
    end

    def sort_dims(values)
      dims_hash = Utility::Dim2D
      values.sort do |first, second|
        dims_hash.dig(first.dimension_name, :order) <=> dims_hash.dig(second.dimension_name, :order)
      end
    end

    def prefixes
      norm_text = @norm_text&.split("-")&.first
      prefix_object = Unit.new("", prefix: Prefix.new(norm_text))
      [
        Utility.prefixes([prefix_object]),
        Utility.dimension(norm_text),
        Utility.quantity(norm_text, explicit_value&.dig(:quantity)),
      ].join
    end
  end
end
