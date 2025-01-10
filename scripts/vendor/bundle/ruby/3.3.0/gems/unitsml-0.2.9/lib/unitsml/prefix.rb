# frozen_string_literal: true

module Unitsml
  class Prefix
    attr_accessor :prefix_name, :only_instance

    def initialize(prefix_name, only_instance = false)
      @prefix_name = prefix_name
      @only_instance = only_instance
    end

    def ==(object)
      self.class == object.class &&
        prefix_name == object&.prefix_name &&
        only_instance == object&.only_instance
    end

    def id
      Unitsdb.prefixes_hash.dig(prefix_name, :id)
    end

    def name
      fields.dig("name")
    end

    def fields
      Unitsdb.prefixes_hash.dig(prefix_name, :fields)
    end

    def prefixes_symbols
      fields&.dig("symbol")
    end

    def to_mathml
      symbol = Utility.string_to_html_entity(
        Utility.html_entity_to_unicode(
          prefixes_symbols["html"]
        ),
      )
      return symbol unless only_instance

      Utility.ox_element("mi") << symbol
    end

    def to_latex
      prefixes_symbols["latex"]
    end

    def to_asciimath
      prefixes_symbols["ascii"]
    end

    def to_html
      prefixes_symbols["html"]
    end

    def to_unicode
      prefixes_symbols["unicode"]
    end

    def symbolid
      prefixes_symbols["ascii"] if prefixes_symbols
    end

    def base
      fields&.dig("base")
    end

    def power
      fields&.dig("power")
    end
  end
end
