# frozen_string_literal: true

require_relative "toml_object"

module Lutaml
  module Model
    module TomlAdapter
      # Base class for TOML documents
      class TomlDocument < TomlObject
        def self.parse(toml, _options = {})
          raise NotImplementedError, "Subclasses must implement `parse`."
        end

        def to_toml(*args)
          raise NotImplementedError, "Subclasses must implement `to_toml`."
        end
      end
    end
  end
end
