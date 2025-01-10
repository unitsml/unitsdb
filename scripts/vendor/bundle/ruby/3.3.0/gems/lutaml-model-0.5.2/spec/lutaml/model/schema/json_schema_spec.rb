require "spec_helper"
require "lutaml/model/schema"

RSpec.describe Lutaml::Model::Schema::JsonSchema do
  module SchemaGeneration
    class Glaze < Lutaml::Model::Serializable
      attribute :color, Lutaml::Model::Type::String
      attribute :finish, Lutaml::Model::Type::String
    end

    class Vase < Lutaml::Model::Serializable
      attribute :height, Lutaml::Model::Type::Float
      attribute :diameter, Lutaml::Model::Type::Float
      attribute :glaze, Glaze
      attribute :materials, Lutaml::Model::Type::String, collection: true
    end
  end

  describe ".generate" do
    it "generates a JSON schema for nested Serialize objects" do
      schema = described_class.generate(SchemaGeneration::Vase,
                                        id: "https://example.com/vase.schema.json", description: "A vase schema", pretty: true)

      expected_schema = <<~JSON.chomp
        {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://example.com/vase.schema.json",
          "description": "A vase schema",
          "$ref": "#/$defs/SchemaGeneration::Vase",
          "$defs": {
            "SchemaGeneration::Vase": {
              "type": "object",
              "properties": {
                "height": {
                  "type": "number"
                },
                "diameter": {
                  "type": "number"
                },
                "glaze": {
                  "$ref": "#/$defs/SchemaGeneration::Glaze"
                },
                "materials": {
                  "type": "array",
                  "items": {
                    "type": "string"
                  }
                }
              },
              "required": [
                "height",
                "diameter",
                "glaze",
                "materials"
              ]
            },
            "SchemaGeneration::Glaze": {
              "type": "object",
              "properties": {
                "color": {
                  "type": "string"
                },
                "finish": {
                  "type": "string"
                }
              },
              "required": [
                "color",
                "finish"
              ]
            }
          }
        }
      JSON

      expect(schema).to eq(expected_schema)
    end
  end
end
