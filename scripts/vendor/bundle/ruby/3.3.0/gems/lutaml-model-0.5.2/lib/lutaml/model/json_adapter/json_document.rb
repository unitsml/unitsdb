# frozen_string_literal: true

require_relative "json_object"

module Lutaml
  module Model
    module JsonAdapter
      # Base class for JSON documents
      class JsonDocument < JsonObject
        def self.parse(json, _options = {})
          raise NotImplementedError, "Subclasses must implement `parse`."
        end

        def to_json(*args)
          raise NotImplementedError, "Subclasses must implement `to_json`."
        end
      end
    end
  end
end
