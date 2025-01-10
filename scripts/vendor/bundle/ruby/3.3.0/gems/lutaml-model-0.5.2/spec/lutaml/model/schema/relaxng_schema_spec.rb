require "spec_helper"
require "lutaml/model/schema"

RSpec.describe Lutaml::Model::Schema::RelaxngSchema do
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
    it "generates a RELAX NG schema for nested Serialize objects" do
      schema = described_class.generate(SchemaGeneration::Vase, pretty: true)

      expected_schema = <<~RELAXNG
        <?xml version="1.0" encoding="UTF-8"?>
        <grammar xmlns="http://relaxng.org/ns/structure/1.0">
          <start>
            <ref name="SchemaGeneration::Vase"/>
          </start>
          <define name="SchemaGeneration::Vase">
            <element name="SchemaGeneration::Vase">
              <element name="height">
                <data type="float"/>
              </element>
              <element name="diameter">
                <data type="float"/>
              </element>
              <ref name="SchemaGeneration::Glaze"/>
              <zeroOrMore>
                <element name="materials">
                  <data type="string"/>
                </element>
              </zeroOrMore>
            </element>
          </define>
          <define name="SchemaGeneration::Glaze">
            <element name="SchemaGeneration::Glaze">
              <element name="color">
                <data type="string"/>
              </element>
              <element name="finish">
                <data type="string"/>
              </element>
            </element>
          </define>
        </grammar>
      RELAXNG
      expect(schema).to eq(expected_schema)
    end
  end
end
