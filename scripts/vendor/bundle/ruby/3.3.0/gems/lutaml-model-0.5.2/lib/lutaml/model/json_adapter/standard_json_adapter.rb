require "json"
require_relative "json_document"

module Lutaml
  module Model
    module JsonAdapter
      class StandardJsonAdapter < JsonDocument
        def self.parse(json, _options = {})
          JSON.parse(json, create_additions: false)
        end

        def to_json(*args)
          JSON.generate(@attributes, *args)
        end
      end
    end
  end
end
