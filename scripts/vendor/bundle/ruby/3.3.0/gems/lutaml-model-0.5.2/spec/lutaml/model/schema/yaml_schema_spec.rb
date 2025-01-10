require "spec_helper"
require "lutaml/model/schema"

RSpec.describe Lutaml::Model::Schema::YamlSchema do
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
    it "generates a YAML schema for nested Serialize objects" do
      schema = described_class.generate(SchemaGeneration::Vase)

      expected_schema = <<~YAML
        ---
        type: map
        mapping:
          height:
            type: float
          diameter:
            type: float
          glaze:
            type: map
            mapping:
              color:
                type: str
              finish:
                type: str
          materials:
            type: seq
            sequence:
            - type: str
      YAML

      expect(schema).to eq(expected_schema)
    end
  end
end
