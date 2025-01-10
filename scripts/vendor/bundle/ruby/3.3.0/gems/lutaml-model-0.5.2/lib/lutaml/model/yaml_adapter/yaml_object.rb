# frozen_string_literal: true

module Lutaml
  module Model
    module YamlAdapter
      # Base class for YAML objects
      class YamlObject
        attr_reader :attributes

        def initialize(attributes = {})
          @attributes = attributes
        end

        def [](key)
          @attributes[key]
        end

        def []=(key, value)
          @attributes[key] = value
        end

        def to_h
          @attributes
        end
      end
    end
  end
end
