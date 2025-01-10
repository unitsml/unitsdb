require "multi_json"
require_relative "json_document"

module Lutaml
  module Model
    module JsonAdapter
      class MultiJsonAdapter < JsonDocument
        def self.parse(json, _options = {})
          data = MultiJson.load(json)
          new(data)
        end

        def to_json(*args)
          MultiJson.dump(to_h, *args)
        end
      end
    end
  end
end
