require "json-schema"

module Lutaml
  module Model
    module Schema
      class JsonSchemaParser
        def self.parse(schema_json)
          schema = JSON::Schema.parse(schema_json)
          definitions = schema.schema.fetch("$defs", {})
          definitions.map do |class_name, class_schema|
            generate_class_definition(class_name, class_schema)
          end.join("\n")
        end

        def self.generate_class_definition(class_name, class_schema)
          attributes = class_schema["properties"] || {}
          required_attributes = class_schema["required"] || []

          <<~RUBY
            class #{class_name} < Lutaml::Model::Serializable
              #{generate_attributes(attributes, required_attributes)}

              json do
                #{generate_json_mappings(attributes)}
              end
            end
          RUBY
        end

        def self.generate_attributes(attributes, required_attributes)
          attributes.map do |name, schema|
            type = schema["type"]
            ruby_type = get_ruby_type(type, schema)
            attributes = [
              "attribute :#{name}",
              "Lutaml::Model::Type::#{ruby_type}",
              "required: #{required_attributes.include?(name).inspect}",
            ]

            attributes.join(", ")
          end.join("\n  ")
        end

        def self.generate_json_mappings(attributes)
          attributes.keys.map do |name|
            "map '#{name}', to: :#{name}"
          end.join("\n    ")
        end

        def self.get_ruby_type(type, schema)
          case type
          when "integer"
            "Integer"
          when "boolean"
            "Boolean"
          when "number"
            "Float"
          when "array"
            item_schema = schema["items"]
            item_type = get_ruby_type(item_schema["type"], item_schema)
            "Array.of(#{item_type})"
          when "object"
            object_class_name(schema)
          else
            "String" # Default to string for unknown types
          end
        end

        def self.object_class_name(schema)
          nested_class_name = schema["title"] || "NestedObject"
          nested_class_definition = generate_class_definition(
            nested_class_name, schema
          )
          @nested_classes ||= []
          @nested_classes << nested_class_definition
          nested_class_name
        end

        def self.nested_classes
          @nested_classes ||= []
        end

        def self.generate(schema_json)
          @nested_classes = []
          main_classes = parse(schema_json)
          (nested_classes + [main_classes]).join("\n")
        end
      end
    end
  end
end
