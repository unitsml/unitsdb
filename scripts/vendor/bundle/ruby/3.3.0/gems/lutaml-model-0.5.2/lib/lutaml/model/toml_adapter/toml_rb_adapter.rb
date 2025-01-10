require "toml-rb"
require_relative "toml_document"

module Lutaml
  module Model
    module TomlAdapter
      class TomlRbAdapter < TomlDocument
        def self.parse(toml, _options = {})
          data = TomlRB.parse(toml)
          new(data)
        end

        def to_toml(*)
          TomlRB.dump(to_h)
        end
      end
    end
  end
end
