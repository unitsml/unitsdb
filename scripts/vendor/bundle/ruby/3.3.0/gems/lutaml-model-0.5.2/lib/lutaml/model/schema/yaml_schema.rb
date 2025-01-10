require "yaml"

module Lutaml
  module Model
    module Schema
      class YamlSchema
        def self.generate(klass, options = {})
          schema = generate_schema(klass)
          options[:pretty] ? schema.to_yaml : YAML.dump(schema)
        end

        def self.generate_schema(klass)
          {
            "type" => "map",
            "mapping" => generate_mapping(klass),
          }
        end

        def self.generate_mapping(klass)
          klass.attributes.each_with_object({}) do |(name, attr), mapping|
            mapping[name.to_s] = generate_attribute_schema(attr)
          end
        end

        def self.generate_attribute_schema(attr)
          if attr.type <= Lutaml::Model::Serialize
            generate_schema(attr.type)
          elsif attr.collection?
            {
              "type" => "seq",
              "sequence" => [{ "type" => get_yaml_type(attr.type) }],
            }
          else
            { "type" => get_yaml_type(attr.type) }
          end
        end

        def self.get_yaml_type(type)
          {
            Lutaml::Model::Type::String => "str",
            Lutaml::Model::Type::Integer => "int",
            Lutaml::Model::Type::Boolean => "bool",
            Lutaml::Model::Type::Float => "float",
            Lutaml::Model::Type::Decimal => "float",
            Lutaml::Model::Type::Hash => "map",
          }[type] || "str" # Default to string for unknown types
        end
      end
    end
  end
end
