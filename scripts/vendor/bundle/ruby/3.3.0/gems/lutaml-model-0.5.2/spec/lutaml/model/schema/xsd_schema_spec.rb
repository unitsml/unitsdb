require "spec_helper"
require "lutaml/model/schema"

RSpec.describe Lutaml::Model::Schema::XsdSchema do
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
    it "generates an XSD schema for nested Serialize objects" do
      schema = described_class.generate(SchemaGeneration::Vase, pretty: true)

      expected_schema = <<~XSD
        <?xml version="1.0" encoding="UTF-8"?>
        <schema xmlns="http://www.w3.org/2001/XMLSchema">
          <element name="SchemaGeneration::Vase">
            <complexType>
              <sequence>
                <element name="height" type="xs:float"/>
                <element name="diameter" type="xs:float"/>
                <element name="glaze">
                  <complexType>
                    <sequence>
                      <element name="color" type="xs:string"/>
                      <element name="finish" type="xs:string"/>
                    </sequence>
                  </complexType>
                </element>
                <element name="materials" minOccurs="0" maxOccurs="unbounded">
                  <complexType>
                    <sequence>
                      <element name="item" type="xs:string"/>
                    </sequence>
                  </complexType>
                </element>
              </sequence>
            </complexType>
          </element>
        </schema>
      XSD

      expect(schema).to eq(expected_schema)
    end
  end
end
