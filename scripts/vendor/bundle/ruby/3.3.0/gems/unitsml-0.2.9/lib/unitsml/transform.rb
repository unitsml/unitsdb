# frozen_string_literal: true

require "parslet"
module Unitsml
  class Transform < Parslet::Transform
    rule(sqrt: simple(:sqrt))       { Sqrt.new(sqrt) }
    rule(units: simple(:unit))      { Unit.new(unit.to_s) }
    rule(prefixes: simple(:prefix)) { Prefix.new(prefix.to_s) }
    rule(dimensions: simple(:dimension)) { Dimension.new(dimension.to_s) }

    rule(units: simple(:unit),
         integer: simple(:integer)) do
      Unit.new(unit.to_s, integer.to_s)
    end

    rule(dimensions: simple(:dimension),
         integer: simple(:integer)) do
      Dimension.new(dimension.to_s, integer.to_s)
    end

    rule(prefixes: simple(:prefix),
         units: simple(:unit)) do
      Unit.new(unit.to_s, prefix: Prefix.new(prefix.to_s))
    end

    rule(prefixes: simple(:prefix),
         units: simple(:unit),
         integer: simple(:integer)) do
      prefix_obj = Prefix.new(prefix.to_s)
      Unit.new(unit.to_s, integer.to_s, prefix: prefix_obj)
    end

    rule(prefixes: simple(:prefix),
         units: simple(:unit),
         integer: simple(:integer),
         extender: simple(:extender),
         sequence: simple(:sequence),) do
      prefix_obj = Prefix.new(prefix.to_s)
      unit_object = Unit.new(unit.to_s, integer.to_s, prefix: prefix_obj)
      Formula.new(
        [
          unit_object,
          Extender.new(extender.to_s),
          sequence,
        ],
      )
    end

    rule(prefixes: simple(:prefix),
         units: simple(:unit),
         extender: simple(:extender),
         sequence: simple(:sequence)) do
      Formula.new(
        [
          Unit.new(unit.to_s, prefix: Prefix.new(prefix.to_s)),
          Extender.new(extender.to_s),
          sequence,
        ],
      )
    end

    rule(units: simple(:unit),
         extender: simple(:extender),
         sequence: simple(:sequence)) do
      Formula.new(
        [
          Unit.new(unit.to_s),
          Extender.new(extender.to_s),
          sequence,
        ],
      )
    end

    rule(units: simple(:unit),
         integer: simple(:integer),
         extender: simple(:extender),
         sequence: simple(:sequence)) do
      Formula.new(
        [
          Unit.new(unit.to_s, integer.to_s),
          Extender.new(extender.to_s),
          sequence,
        ],
      )
    end

    rule(dimensions: simple(:dimension),
         extender: simple(:extender),
         sequence: simple(:sequence)) do
      Formula.new(
        [
          Dimension.new(dimension.to_s),
          Extender.new(extender.to_s),
          sequence,
        ],
      )
    end

    rule(dimensions: simple(:dimension),
         integer: simple(:integer),
         extender: simple(:extender),
         sequence: simple(:sequence)) do
      Formula.new(
        [
          Dimension.new(dimension.to_s, integer.to_s),
          Extender.new(extender.to_s),
          sequence,
        ],
      )
    end
  end
end
