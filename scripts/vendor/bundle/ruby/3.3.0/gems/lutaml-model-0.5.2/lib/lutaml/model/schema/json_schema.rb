require "json"

module Lutaml
  module Model
    module Schema
      class JsonSchema
        def self.generate(klass, options = {})
          schema = {
            "$schema" => "https://json-schema.org/draft/2020-12/schema",
            "$id" => options[:id],
            "description" => options[:description],
            "$ref" => "#/$defs/#{klass.name}",
            "$defs" => generate_definitions(klass),
          }.compact

          options[:pretty] ? JSON.pretty_generate(schema) : schema.to_json
        end

        def self.generate_definitions(klass)
          defs = { klass.name => generate_class_schema(klass) }
          klass.attributes.each_value do |attr|
            if attr.type <= Lutaml::Model::Serialize
              defs.merge!(generate_definitions(attr.type))
            end
          end
          defs
        end

        def self.generate_class_schema(klass)
          {
            "type" => "object",
            "properties" => generate_properties(klass),
            "required" => klass.attributes.keys,
          }
        end

        def self.generate_properties(klass)
          klass.attributes.transform_values do |attr|
            generate_property_schema(attr)
          end
        end

        def self.generate_property_schema(attr)
          if attr.type <= Lutaml::Model::Serialize
            { "$ref" => "#/$defs/#{attr.type.name}" }
          elsif attr.collection?
            {
              "type" => "array",
              "items" => { "type" => get_json_type(attr.type) },
            }
          else
            { "type" => get_json_type(attr.type) }
          end
        end

        def self.get_json_type(type)
          {
            Lutaml::Model::Type::String => "string",
            Lutaml::Model::Type::Integer => "integer",
            Lutaml::Model::Type::Boolean => "boolean",
            Lutaml::Model::Type::Float => "number",
            Lutaml::Model::Type::Hash => "object",
          }[type] || "string" # Default to string for unknown types
        end
      end
    end
  end
end
