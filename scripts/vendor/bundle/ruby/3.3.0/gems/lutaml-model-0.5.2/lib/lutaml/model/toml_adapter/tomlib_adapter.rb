require "tomlib"
require_relative "toml_document"

module Lutaml
  module Model
    module TomlAdapter
      class TomlibAdapter < TomlDocument
        def self.parse(toml, _options = {})
          data = Tomlib.load(toml)
          new(data)
        end

        def to_toml(*args)
          Tomlib.dump(to_h, *args)
          # Tomlib::Generator.new(to_h).toml_str
        end
      end
    end
  end
end
