# frozen_string_literal: true

require "ox"
module Unitsml
  module Utility

    UNITSML_NS = "https://schema.unitsml.org/unitsml/1.0".freeze
    # Unit to dimension
    U2D = {
      "m" => { dimension: "Length", order: 1, symbol: "L" },
      "g" => { dimension: "Mass", order: 2, symbol: "M" },
      "kg" => { dimension: "Mass", order: 2, symbol: "M" },
      "s" => { dimension: "Time", order: 3, symbol: "T" },
      "A" => { dimension: "ElectricCurrent", order: 4, symbol: "I" },
      "K" => { dimension: "ThermodynamicTemperature", order: 5,
               symbol: "Theta" },
      "degK" => { dimension: "ThermodynamicTemperature", order: 5,
                  symbol: "Theta" },
      "mol" => { dimension: "AmountOfSubstance", order: 6, symbol: "N" },
      "cd" => { dimension: "LuminousIntensity", order: 7, symbol: "J" },
      "deg" => { dimension: "PlaneAngle", order: 8, symbol: "phi" },
    }.freeze
    # Dimesion for dim_(dimesion) input
    Dim2D = {
      "dim_L" => U2D["m"],
      "dim_M" => U2D["g"],
      "dim_T" => U2D["s"],
      "dim_I" => U2D["A"],
      "dim_Theta" => U2D["K"],
      "dim_N" => U2D["mol"],
      "dim_J" => U2D["cd"],
      "dim_phi" => U2D["deg"],
    }.freeze
    DIMS_VECTOR = %w[
      ThermodynamicTemperature
      AmountOfSubstance
      LuminousIntensity
      ElectricCurrent
      PlaneAngle
      Length
      Mass
      Time
    ].freeze

    class << self
      include Unitsml::Unitsdb

      def fields(unit)
        Unitsdb.units.dig(unit, :fields)
      end

      def units2dimensions(units)
        norm = decompose_units_list(units)
        return if norm.any? { |u| u.nil? || u[:unit].unit_name == "unknown" || u[:prefix] == "unknown" }

        norm.map do |u|
          unit_name = u[:unit].unit_name
          {
            dimension: U2D[unit_name][:dimension],
            unit: unit_name,
            exponent: u[:unit].power_numerator || 1,
            symbol: U2D[unit_name][:symbol],
          }
        end.sort { |a, b| U2D[a[:unit]][:order] <=> U2D[b[:unit]][:order] }
      end

      def dim_id(dims)
        return nil if dims.nil? || dims.empty?

        dimensions = Unitsdb.dimensions_hash.values
        dim_hash = dims.each_with_object({}) { |h, m| m[h[:dimension]] = h }
        dims_vector = DIMS_VECTOR.map { |h| dim_hash.dig(h, :exponent) }.join(":")
        id = dimensions.select { |d| d[:vector] == dims_vector }&.first&.dig(:id) and return id.to_s
        "D_" + dims.map do |d|
          (U2D.dig(d[:unit], :symbol) || Dim2D.dig(d[:id], :symbol)) +
            (d[:exponent] == 1 ? "" : float_to_display(d[:exponent]))
        end.join("")
      end

      def decompose_units_list(units)
        gather_units(units.map { |u| decompose_unit(u) }.flatten)
      end

      def decompose_unit(u)
        if u&.unit_name == "g" || u.system_type == "SI_base"
          { unit: u, prefix: u&.prefix }
        elsif !u.si_derived_bases
          { unit: Unit.new("unknown") }
        else
          u.si_derived_bases.each_with_object([]) do |k, m|
            prefix = if !k["prefix"].nil? && !k["prefix"].empty?
                       combine_prefixes(prefix_object(k["prefix"]), u.prefix)
                     else
                       u.prefix
                     end
            unit_name = Unitsdb.load_units.dig(k.dig("id"), "unit_symbols", 0, "id")
            exponent = (k["power"]&.to_i || 1) * (u.power_numerator&.to_f || 1)
            m << { prefix: prefix,
                   unit: Unit.new(unit_name, exponent, prefix: prefix),
                 }
          end
        end
      end

      def gather_units(units)
        units.sort_by { |a| a[:unit]&.unit_name }.each_with_object([]) do |k, m|
          if m.empty? || m[-1][:unit]&.unit_name != k[:unit]&.unit_name
            m << k
          else
            m[-1][:unit]&.power_numerator = (k[:unit]&.power_numerator&.to_f || 1) + (m[-1][:unit]&.power_numerator&.to_f || 1)
            m[-1] = {
              prefix: combine_prefixes(prefix_object(m[-1][:prefix]), prefix_object(k[:prefix])),
              unit: m[-1][:unit],
            }
          end
        end
      end

      def prefix_object(prefix)
        return prefix unless prefix.is_a?(String)
        return nil unless Unitsdb.prefixes.any?(prefix)

        prefix.is_a?(String) ? Prefix.new(prefix) : prefix
      end

      def combine_prefixes(p1, p2)
        return nil if p1.nil? && p2.nil?
        return p1.symbolid if p2.nil?
        return p2.symbolid if p1.nil?
        return "unknown" if p1.base != p2.base

        Unitsdb.prefixes_hash.each do |prefix_name, _|
          p = prefix_object(prefix_name)
          return p if p.base == p1.base && p.power == p1.power + p2.power
        end

        "unknown"
      end

      def unit(units, formula, dims, norm_text, name)
        attributes = { xmlns: UNITSML_NS, "xml:id": unit_id(norm_text) }
        attributes[:dimensionURL] = "##{dim_id(dims)}" if dims
        unit_node = ox_element("Unit", attributes: attributes)
        nodes = Array(unitsystem(units))
        nodes += Array(unitname(units, norm_text, name))
        nodes += Array(unitsymbols(formula))
        nodes += Array(rootunits(units))
        Ox.dump(update_nodes(unit_node, nodes))
          .gsub("&lt;", "<")
          .gsub("&gt;", ">")
          .gsub("&amp;", "&")
          .gsub(/−/, "&#x2212;")
          .gsub(/⋅/, "&#x22c5;")
      end

      def unitname(units, text, name)
        name ||= Unitsdb.units[text] ? Unit.new(text).enumerated_name : text
        ox_element("UnitName", attributes: { "xml:lang": "en" }) << name
      end

      def postprocess_normtext(units)
        units.map { |u| "#{u.prefix_name}#{u.unit_name}#{display_exp(u)}" }.join("*")
      end

      def display_exp(unit)
        unit.power_numerator && unit.power_numerator != "1" ? "^#{unit.power_numerator}" : ""
      end

      def unitsymbols(formula)
        [
          (ox_element("UnitSymbol", attributes: { type: "HTML" }) << formula.to_html),
          (ox_element("UnitSymbol", attributes: { type: "MathMl" }) << Ox.parse(formula.to_mathml)),
        ]
      end

      def unitsystem(units)
        ret = []
        if units.any? { |u| u.system_name != "SI" }
          ret << ox_element("UnitSystem", attributes: { name: "not_SI", type: "not_SI", "xml:lang": 'en-US' })
        end
        if units.any? { |u| u.system_name == "SI" }
          if units.size == 1
            base = units[0].system_type == "SI-base"
            base = true if units[0].unit_name == "g" && units[0]&.prefix_name == "k"
          end
          ret << ox_element("UnitSystem", attributes: { name: "SI", type: (base ? 'SI_base' : 'SI_derived'), "xml:lang": 'en-US' })
        end
        ret
      end

      def dimension(norm_text)
        return unless fields(norm_text)&.dig("dimension_url")

        dim_id = fields(norm_text).dig("dimension_url").sub("#", '')
        dim_node = ox_element("Dimension", attributes: { xmlns: UNITSML_NS, "xml:id": dim_id })
        Ox.dump(
          update_nodes(
            dim_node,
            dimid2dimensions(dim_id)&.compact&.map { |u| dimension1(u) }
          )
        )
      end

      def dimension1(dim)
        attributes = {
          symbol: dim[:symbol],
          powerNumerator: float_to_display(dim[:exponent])
        }
        ox_element(dim[:dimension], attributes: attributes)
      end

      def float_to_display(float)
        float.to_f.round(1).to_s.sub(/\.0$/, "")
      end

      def dimid2dimensions(normtext)
        dims ||= Unitsdb.load_dimensions[normtext]
        dims&.keys&.reject { |d| d.is_a?(Symbol) }&.map do |k|
          humanized = k.split("_").map(&:capitalize).join
          next unless DIMS_VECTOR.include?(humanized)

          {
            dimension: humanized,
            symbol: dims.dig(k, "symbol"),
            exponent: dims.dig(k, "powerNumerator")
          }
        end
      end

      def prefixes(units)
        uniq_prefixes = units.map { |unit| unit.prefix }.compact.uniq {|d| d.prefix_name }
        uniq_prefixes.map do |p|
          prefix_attr = { xmlns: UNITSML_NS, prefixBase: p&.base, prefixPower: p&.power, "xml:id": p&.id }
          prefix_node = ox_element("Prefix", attributes: prefix_attr)
          contents = []
          contents << (ox_element("PrefixName", attributes: { "xml:lang": "en" }) << p&.name)
          contents << (ox_element("PrefixSymbol", attributes: { type: "ASCII" }) << p&.to_asciimath)
          contents << (ox_element("PrefixSymbol", attributes: { type: "unicode" }) << p&.to_unicode)
          contents << (ox_element("PrefixSymbol", attributes: { type: "LaTex" }) << p&.to_latex)
          contents << (ox_element("PrefixSymbol", attributes: { type: "HTML" }) << p&.to_html)
          Ox.dump(update_nodes(prefix_node, contents)).gsub("&amp;", "&")
        end.join("\n")
      end

      def rootunits(units)
        return if units.size == 1 && !units[0].prefix

        root_unit = ox_element("RootUnits")
        units.each do |u|
          attributes = { unit: u.enumerated_name }
          attributes[:prefix] = u.prefix_name if u.prefix
          u.power_numerator && u.power_numerator != "1" and
            attributes[:powerNumerator] = u.power_numerator
          root_unit << ox_element("EnumeratedRootUnit", attributes: attributes)
        end
        root_unit
      end

      def unit_id(text)
        norm_text = text
        text = text&.gsub(/[()]/, "")
        /-$/.match(text) and return Unitsdb.prefixes[text.sub(/-$/, "")][:id]
        unit_hash = Unitsdb.units[norm_text]
        "U_#{unit_hash ? unit_hash[:id]&.gsub(/'/, '_') : norm_text&.gsub(/\*/, '.')&.gsub(/\^/, '')}"
      end

      def dimension_components(dims)
        return if dims.nil? || dims.empty?

        attributes = { xmlns: UNITSML_NS, "xml:id": dim_id(dims) }
        dim_node = ox_element("Dimension", attributes: attributes)
        Ox.dump(update_nodes(dim_node, dims.map { |u| dimension1(u) }))
      end

      def quantity(normtext, quantity)
        units = Unitsdb.units
        quantity_references = units.dig(normtext, :fields, "quantity_reference")
        return unless units[normtext] && quantity_references.size == 1 ||
          Unitsdb.quantities[quantity]

        id = quantity || quantity_references&.first&.dig("url")
        attributes = { xmlns: UNITSML_NS, "xml:id": id.sub('#', '') }
        dim_url = units.dig(normtext, :fields, "dimension_url")
        dim_url and attributes[:dimensionURL] = "#{dim_url}"
        attributes[:quantityType] = "base"
        quantity_element = ox_element("Quantity", attributes: attributes)
        Ox.dump(update_nodes(quantity_element, quantity_name(id.sub('#', ''))))
      end

      def quantity_name(id)
        ret = []
        Unitsdb.quantities[id]&.dig("quantity_name")&.each do |q|
          node = (ox_element("QuantityName", attributes: { "xml:lang": "en-US" }) << q)
          ret << node
        end
        ret
      end

      def ox_element(node, attributes: [])
        element = Ox::Element.new(node)
        attributes&.each { |attr_key, attr_value| element[attr_key] = attr_value }
        element
      end

      def update_nodes(element, nodes)
        nodes&.each { |node| element << node unless node.nil? }
        element
      end

      def string_to_html_entity(string)
        entities = HTMLEntities.new
        entities.encode(
          string.frozen? ? string : string.force_encoding('UTF-8'),
          :hexadecimal,
        )
      end

      def html_entity_to_unicode(string)
        entities = HTMLEntities.new
        entities.decode(string)
      end
    end
  end
end
