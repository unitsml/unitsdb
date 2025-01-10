# frozen_string_literal: true

require_relative "yaml_object"

module Lutaml
  module Model
    module YamlAdapter
      # Base class for YAML documents
      class YamlDocument < YamlObject
        def self.parse(yaml, _options = {})
          raise NotImplementedError, "Subclasses must implement `parse`."
        end

        def to_yaml(*args)
          raise NotImplementedError, "Subclasses must implement `to_yaml`."
        end
      end
    end
  end
end
