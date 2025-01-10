# frozen_string_literal: true

require "parslet"
require_relative "unitsdb"
module Unitsml
  class Parse < Parslet::Parser
    include Unitsml::Unitsdb

    rule(:power)    { str("^") >> intermediate_exp(number) }
    rule(:hyphen)   { str("-") }
    rule(:number)   { (hyphen.maybe >> match(/[0-9]/).repeat(1)).as(:integer) }
    rule(:extender) { (str("//") | str("/") | str("*")).as(:extender) }
    rule(:sequence) { single_letter_prefixes >> units | double_letter_prefixes >> units | units }
    rule(:unit_and_power) { units >> power.maybe }

    rule(:units) do
      @@filtered_units ||= arr_to_expression(Unitsdb.filtered_units, "units")
    end

    rule(:single_letter_prefixes) do
      @@prefixes1 ||= arr_to_expression(Unitsdb.prefixes.select { |p| p.size == 1 }, "prefixes")
    end

    rule(:double_letter_prefixes) do
      @@prefixes2 ||= arr_to_expression(Unitsdb.prefixes.select { |p| p.size == 2 }, "prefixes")
    end

    rule(:dimensions) do
      @@dimensions ||= arr_to_expression(Unitsdb.parsable_dimensions.keys, "dimensions")
    end

    rule(:prefixes_units) do
      (sqrt(sequence) >> extend_exp(prefixes_units)) |
        (str("1").as(:units) >> extend_exp(prefixes_units)) |
        (unit_and_power >> extender >> intermediate_exp(prefixes_units).as(:sequence)) |
        unit_and_power |
        (single_letter_prefixes >> unit_and_power >> extender >> intermediate_exp(prefixes_units).as(:sequence)) |
        (single_letter_prefixes >> unit_and_power) |
        (double_letter_prefixes >> unit_and_power >> extender >> intermediate_exp(prefixes_units).as(:sequence)) |
        (double_letter_prefixes >> unit_and_power)
    end

    rule(:dimension_rules) do
      (sqrt(intermediate_exp(dimensions >> power.maybe)) >> extend_exp(dimension_rules)) |
        (dimensions >> power.maybe >> extend_exp(dimension_rules))
    end

    rule(:expression) do
      intermediate_exp(prefixes_units) |
        intermediate_exp(dimension_rules) |
        single_letter_prefixes >> hyphen |
        double_letter_prefixes >> hyphen
    end

    root :expression

    def arr_to_expression(arr, file_name)
      array = arr&.flatten&.compact&.sort_by(&:length).reverse
      array&.reduce do |expression, expr_string|
        expression = str(expression).as(file_name.to_sym) if expression.is_a?(String)
        expression | str(expr_string).as(file_name.to_sym)
      end
    end

    def sqrt(rule)
      str("sqrt(") >> rule.as(:sqrt) >> str(")")
    end

    def extend_exp(rule)
      (extender >> intermediate_exp(rule).as(:sequence)).maybe
    end

    def intermediate_exp(rule)
      rule | (str("(") >> rule >> str(")"))
    end
  end
end
