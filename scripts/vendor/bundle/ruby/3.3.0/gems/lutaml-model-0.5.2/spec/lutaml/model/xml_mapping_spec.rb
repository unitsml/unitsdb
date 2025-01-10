require "spec_helper"

require "lutaml/model/xml_adapter/ox_adapter"
require "lutaml/model/xml_adapter/oga_adapter"

require_relative "../../../lib/lutaml/model/xml_mapping"
require_relative "../../../lib/lutaml/model/xml_mapping_rule"

# Define a sample class for testing map_content
class Italic < Lutaml::Model::Serializable
  attribute :text, Lutaml::Model::Type::String, collection: true

  xml do
    root "i"
    map_content to: :text
  end
end

# Define a sample class for testing p tag
class Paragraph < Lutaml::Model::Serializable
  attribute :text, Lutaml::Model::Type::String
  attribute :paragraph, Paragraph

  xml do
    root "p"

    map_content to: :text
    map_element "p", to: :paragraph
  end
end

module XmlMapping
  class ChildNamespaceNil < Lutaml::Model::Serializable
    attribute :element_default_namespace, :string
    attribute :element_nil_namespace, :string
    attribute :element_new_namespace, :string

    xml do
      root "ChildNamespaceNil"
      namespace "http://www.omg.org/spec/XMI/20131001", "xmi"

      # this will inherit the namespace from the parent i.e <xmi:ElementDefaultNamespace>
      map_element "ElementDefaultNamespace", to: :element_default_namespace

      # this will have nil namesapce applied i.e <ElementNilNamespace>
      map_element "ElementNilNamespace", to: :element_nil_namespace,
                                         prefix: nil,
                                         namespace: nil

      # this will have new namespace i.e <new:ElementNewNamespace>
      map_element "ElementNewNamespace", to: :element_new_namespace,
                                         prefix: "new",
                                         namespace: "http://www.omg.org/spec/XMI/20161001"
    end
  end

  class Address < Lutaml::Model::Serializable
    attribute :street, ::Lutaml::Model::Type::String, raw: true
    attribute :city, :string, raw: true
    attribute :address, Address

    xml do
      root "address"

      map_element "street", to: :street
      map_element "city", to: :city
    end
  end

  class Person < Lutaml::Model::Serializable
    attribute :name, Lutaml::Model::Type::String
    attribute :address, XmlMapping::Address
  end

  class Mfenced < Lutaml::Model::Serializable
    attribute :open, :string

    xml do
      root "mfenced"
      map_attribute "open", to: :open
    end
  end

  class MmlMath < Lutaml::Model::Serializable
    attribute :mfenced, Mfenced

    xml do
      root "math"
      namespace "http://www.w3.org/1998/Math/MathML"
      map_element :mfenced, to: :mfenced
    end
  end

  class AttributeNamespace < Lutaml::Model::Serializable
    attribute :alpha, :string
    attribute :beta, :string

    xml do
      root "example"
      namespace "http://www.check.com", "ns1"

      map_attribute "alpha", to: :alpha,
                             namespace: "http://www.example.com",
                             prefix: "ex1"

      map_attribute "beta", to: :beta
    end
  end

  class SameNameDifferentNamespace < Lutaml::Model::Serializable
    attribute :gml_application_schema, :string
    attribute :citygml_application_schema, :string
    attribute :application_schema, :string
    attribute :app, :string

    xml do
      root "SameElementName"
      namespace "http://www.omg.org/spec/XMI/20131001", nil

      map_element "ApplicationSchema", to: :gml_application_schema,
                                       namespace: "http://www.sparxsystems.com/profiles/GML/1.0",
                                       prefix: "GML"

      map_element "ApplicationSchema", to: :citygml_application_schema,
                                       namespace: "http://www.sparxsystems.com/profiles/CityGML/1.0",
                                       prefix: "CityGML"

      map_element "ApplicationSchema", to: :application_schema

      map_attribute "App", to: :app
    end
  end

  class OverrideDefaultNamespacePrefix < Lutaml::Model::Serializable
    attribute :same_element_name, SameNameDifferentNamespace

    xml do
      root "OverrideDefaultNamespacePrefix"
      map_element :SameElementName, to: :same_element_name,
                                    namespace: "http://www.omg.org/spec/XMI/20131001",
                                    prefix: "abc"
    end
  end

  class SchemaLocationOrdered < Lutaml::Model::Serializable
    attribute :content, :string
    attribute :second, SchemaLocationOrdered

    xml do
      root "schemaLocationOrdered", mixed: true

      map_content to: :content
      map_element "schemaLocationOrdered", to: :second
    end
  end

  class ToBeDuplicated < Lutaml::Model::Serializable
    attribute :content, :string
    attribute :element, :string
    attribute :attribute, :string

    xml do
      root "ToBeDuplicated"
      namespace "https://testing-duplicate", "td"

      map_content to: :content
      map_attribute "attribute", to: :attribute
      map_element "element", to: :element,
                             namespace: "https://test-element",
                             prefix: "te"
    end
  end

  class SpecialCharContentWithMapAll < Lutaml::Model::Serializable
    attribute :all_content, :string

    xml do
      root "SpecialCharContentWithMapAll"

      map_all to: :all_content
    end
  end

  class MapAllWithCustomMethod < Lutaml::Model::Serializable
    attribute :all_content, :string

    xml do
      root "MapAllWithCustomMethod"

      map_all to: :all_content, with: { to: :content_to_xml, from: :content_from_xml }
    end

    def content_to_xml(model, parent, doc)
      content = model.all_content.sub(/^<div>/, "").sub(/<\/div>$/, "")
      doc.add_xml_fragment(parent, content)
    end

    def content_from_xml(model, value)
      model.all_content = "<div>#{value}</div>"
    end
  end

  class WithMapAll < Lutaml::Model::Serializable
    attribute :all_content, :string
    attribute :attr, :string

    xml do
      root "WithMapAll"

      map_all to: :all_content
    end
  end

  class WithoutMapAll < Lutaml::Model::Serializable
    attribute :content, :string

    xml do
      root "WithoutMapAll"

      map_content to: :content
    end
  end

  class WithNestedMapAll < Lutaml::Model::Serializable
    attribute :age, :integer
    attribute :name, :string
    attribute :description, WithMapAll

    xml do
      root "WithNestedMapAll"

      map_attribute :age, to: :age
      map_element :name, to: :name
      map_element :description, to: :description
    end
  end

  class WithChildExplicitNamespace < Lutaml::Model::Serializable
    attribute :with_default_namespace, :string
    attribute :with_namespace, :string
    attribute :without_namespace, :string

    xml do
      root "WithChildExplicitNamespaceNil"
      namespace "http://parent-namespace", "pn"

      map_element "DefaultNamespace", to: :with_default_namespace

      map_element "WithNamespace", to: :with_namespace,
                                   namespace: "http://child-namespace",
                                   prefix: "cn"

      map_element "WithoutNamespace", to: :without_namespace,
                                      namespace: nil,
                                      prefix: nil
    end
  end

  class Documentation < Lutaml::Model::Serializable
    attribute :content, :string

    xml do
      root "documentation", mixed: true
      namespace "http://www.w3.org/2001/XMLSchema", "xsd"

      map_content to: :content
    end
  end

  class Schema < Lutaml::Model::Serializable
    attribute :documentation, Documentation, collection: true

    xml do
      root "schema"
      namespace "http://www.w3.org/2001/XMLSchema", "xsd"

      map_element :documentation, to: :documentation,
                                  namespace: "http://www.w3.org/2001/XMLSchema",
                                  prefix: "xsd"
    end
  end
end

RSpec.describe Lutaml::Model::XmlMapping do
  shared_examples "having XML Mappings" do |adapter_class|
    around do |example|
      old_adapter = Lutaml::Model::Config.xml_adapter
      Lutaml::Model::Config.xml_adapter = adapter_class

      example.run
    ensure
      Lutaml::Model::Config.xml_adapter = old_adapter
    end

    let(:mapping) { Lutaml::Model::XmlMapping.new }

    context "attribute namespace" do
      input_xml = <<~XML
        <ns1:example ex1:alpha="hello"
                     beta="bye"
                     xmlns:ns1="http://www.check.com"
                     xmlns:ex1="http://www.example.com">
        </ns1:example>
      XML

      it "checks the attribute with and without namespace" do
        parsed = XmlMapping::AttributeNamespace.from_xml(input_xml)
        expect(parsed.alpha).to eq("hello")
        expect(parsed.beta).to eq("bye")
        expect(parsed.to_xml).to be_equivalent_to(input_xml)
      end
    end

    context "explicit namespace" do
      mml = <<~XML
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <mfenced open="("></mfenced>
        </math>
      XML

      it "nil namespace" do
        parsed = XmlMapping::MmlMath.from_xml(mml)
        expect(parsed.to_xml).to be_equivalent_to(mml)
      end
    end

    # Skipping for OX because it does not handle namespaces
    context "overriding child namespace prefix", skip: adapter_class == Lutaml::Model::XmlAdapter::OxAdapter do
      let(:input_xml) do
        <<~XML
          <OverrideDefaultNamespacePrefix
              xmlns:abc="http://www.omg.org/spec/XMI/20131001"
              xmlns:GML="http://www.sparxsystems.com/profiles/GML/1.0"
              xmlns:CityGML="http://www.sparxsystems.com/profiles/CityGML/1.0">

            <abc:SameElementName App="hello">
              <GML:ApplicationSchema>GML App</GML:ApplicationSchema>
              <CityGML:ApplicationSchema>CityGML App</CityGML:ApplicationSchema>
              <abc:ApplicationSchema>App</abc:ApplicationSchema>
            </abc:SameElementName>
          </OverrideDefaultNamespacePrefix>
        XML
      end

      let(:oga_expected_xml) do
        "<OverrideDefaultNamespacePrefix xmlns:abc=\"http://www.omg.org/spec/XMI/20131001\">" +
          "<abc:SameElementName App=\"hello\" xmlns:GML=\"http://www.sparxsystems.com/profiles/GML/1.0\" xmlns:CityGML=\"http://www.sparxsystems.com/profiles/CityGML/1.0\">" +
          "<GML:ApplicationSchema>GML App</GML:ApplicationSchema>" +
          "<CityGML:ApplicationSchema>CityGML App</CityGML:ApplicationSchema>" +
          "<abc:ApplicationSchema>App</abc:ApplicationSchema>" +
          "</abc:SameElementName>" +
          "</OverrideDefaultNamespacePrefix>"
      end

      it "expect to round-trips" do
        parsed = XmlMapping::OverrideDefaultNamespacePrefix.from_xml(input_xml)
        expected_xml = adapter_class.type == "oga" ? oga_expected_xml : input_xml
        expect(parsed.to_xml).to be_equivalent_to(expected_xml)
      end
    end

    context "with same name elements" do
      let(:input_xml) do
        <<~XML
          <SameElementName App="hello"
              xmlns="http://www.omg.org/spec/XMI/20131001"
              xmlns:GML="http://www.sparxsystems.com/profiles/GML/1.0"
              xmlns:CityGML="http://www.sparxsystems.com/profiles/CityGML/1.0">

            <GML:ApplicationSchema>GML App</GML:ApplicationSchema>
            <CityGML:ApplicationSchema>CityGML App</CityGML:ApplicationSchema>
            <ApplicationSchema>App</ApplicationSchema>
          </SameElementName>
        XML
      end

      let(:expected_order) do
        {
          Lutaml::Model::XmlAdapter::NokogiriAdapter => [
            "text",
            "ApplicationSchema",
            "text",
            "ApplicationSchema",
            "text",
            "ApplicationSchema",
            "text",
          ],
          Lutaml::Model::XmlAdapter::OxAdapter => [
            "ApplicationSchema",
            "ApplicationSchema",
            "ApplicationSchema",
          ],
          Lutaml::Model::XmlAdapter::OgaAdapter => [
            "text",
            "ApplicationSchema",
            "text",
            "ApplicationSchema",
            "text",
            "ApplicationSchema",
            "text",
          ],
        }
      end

      let(:parsed) { XmlMapping::SameNameDifferentNamespace.from_xml(input_xml) }

      it "citygml_application_schema should be correct" do
        expect(parsed.citygml_application_schema).to eq("CityGML App")
      end

      it "gml_application_schema should be correct" do
        expect(parsed.gml_application_schema).to eq("GML App")
      end

      it "application_schema should be correct" do
        expect(parsed.application_schema).to eq("App")
      end

      it "app should be correct" do
        expect(parsed.app).to eq("hello")
      end

      it "element_order should be correct" do
        expect(parsed.element_order).to eq(expected_order[adapter_class])
      end

      it "to_xml should be correct" do
        expect(parsed.to_xml).to be_equivalent_to(input_xml)
      end
    end

    context "with elements have different prefixed namespaces" do
      before do
        mapping.root("XMI")
        mapping.namespace("http://www.omg.org/spec/XMI/20131001")
        mapping.map_element(
          "ApplicationSchema",
          to: :gml_application_schema,
          namespace: "http://www.sparxsystems.com/profiles/GML/1.0",
          prefix: "GML",
        )
        mapping.map_element(
          "ApplicationSchema",
          to: :citygml_application_schema,
          namespace: "http://www.sparxsystems.com/profiles/CityGML/1.0",
          prefix: "CityGML",
        )
        mapping.map_element(
          "ApplicationSchema",
          to: :citygml_application_schema,
          namespace: "http://www.sparxsystems.com/profiles/CGML/1.0",
          prefix: "CGML",
        )
      end

      it "maps elements correctly" do
        expect(mapping.elements[0].namespace).to eq("http://www.sparxsystems.com/profiles/GML/1.0")
        expect(mapping.elements[1].namespace).to eq("http://www.sparxsystems.com/profiles/CityGML/1.0")
        expect(mapping.elements[2].namespace).to eq("http://www.sparxsystems.com/profiles/CGML/1.0")
        expect(mapping.elements.size).to eq(3)
      end
    end

    context "with child having explicit namespaces" do
      let(:xml) do
        <<~XML.strip
          <pn:WithChildExplicitNamespaceNil xmlns:pn="http://parent-namespace" xmlns:cn="http://child-namespace">
            <pn:DefaultNamespace>default namespace text</pn:DefaultNamespace>
            <cn:WithNamespace>explicit namespace text</cn:WithNamespace>
            <WithoutNamespace>without namespace text</WithoutNamespace>
          </pn:WithChildExplicitNamespaceNil>
        XML
      end

      let(:parsed) do
        XmlMapping::WithChildExplicitNamespace.from_xml(xml)
      end

      it "reads element with default namespace" do
        expect(parsed.with_default_namespace).to eq("default namespace text")
      end

      it "reads element with explicit namespace" do
        expect(parsed.with_namespace).to eq("explicit namespace text")
      end

      it "reads element without namespace" do
        expect(parsed.without_namespace).to eq("without namespace text")
      end

      it "round-trips xml with child explicit namespace" do
        expect(parsed.to_xml).to be_equivalent_to(xml)
      end
    end

    context "with default namespace" do
      before do
        mapping.root("ceramic")
        mapping.namespace("https://example.com/ceramic/1.2")
        mapping.map_element("type", to: :type)
        mapping.map_element("color", to: :color, delegate: :glaze)
        mapping.map_element("finish", to: :finish, delegate: :glaze)
      end

      it "sets the default namespace for the root element" do
        expect(mapping.namespace_uri).to eq("https://example.com/ceramic/1.2")
        expect(mapping.namespace_prefix).to be_nil
      end

      it "maps elements correctly" do
        expect(mapping.elements.size).to eq(3)
        expect(mapping.elements[0].name).to eq("type")
        expect(mapping.elements[1].delegate).to eq(:glaze)
      end
    end

    context "with prefixed namespace" do
      before do
        mapping.root("ceramic")
        mapping.namespace("https://example.com/ceramic/1.2", "cera")
        mapping.map_element("type", to: :type)
        mapping.map_element("color", to: :color, delegate: :glaze)
        mapping.map_element("finish", to: :finish, delegate: :glaze)
      end

      it "sets the namespace with prefix for the root element" do
        expect(mapping.namespace_uri).to eq("https://example.com/ceramic/1.2")
        expect(mapping.namespace_prefix).to eq("cera")
      end

      it "maps elements correctly" do
        expect(mapping.elements.size).to eq(3)
        expect(mapping.elements[0].name).to eq("type")
        expect(mapping.elements[1].delegate).to eq(:glaze)
      end
    end

    context "with element-level namespace" do
      before do
        mapping.root("ceramic")
        mapping.map_element(
          "type",
          to: :type,
          namespace: "https://example.com/ceramic/1.2",
          prefix: "cera",
        )
        mapping.map_element("color", to: :color, delegate: :glaze)
        mapping.map_element("finish", to: :finish, delegate: :glaze)
      end

      it "sets the namespace for individual elements" do
        expect(mapping.elements.size).to eq(3)
        expect(mapping.elements[0].namespace).to eq("https://example.com/ceramic/1.2")
        expect(mapping.elements[0].prefix).to eq("cera")
        expect(mapping.elements[1].delegate).to eq(:glaze)
      end
    end

    context "with attribute-level namespace" do
      before do
        mapping.root("ceramic")
        mapping.map_attribute(
          "date",
          to: :date,
          namespace: "https://example.com/ceramic/1.2",
          prefix: "cera",
        )
        mapping.map_element("type", to: :type)
        mapping.map_element("color", to: :color, delegate: :glaze)
        mapping.map_element("finish", to: :finish, delegate: :glaze)
      end

      it "sets the namespace for individual attributes" do
        expect(mapping.attributes.size).to eq(1)
        expect(mapping.attributes[0].namespace).to eq("https://example.com/ceramic/1.2")
        expect(mapping.attributes[0].prefix).to eq("cera")
      end
    end

    context "with nil element-level namespace" do
      let(:expected_xml) do
        <<~XML
          <xmi:ChildNamespaceNil xmlns:xmi="http://www.omg.org/spec/XMI/20131001" xmlns:new="http://www.omg.org/spec/XMI/20161001">
            <xmi:ElementDefaultNamespace>Default namespace</xmi:ElementDefaultNamespace>
            <ElementNilNamespace>No namespace</ElementNilNamespace>
            <new:ElementNewNamespace>New namespace</new:ElementNewNamespace>
          </xmi:ChildNamespaceNil>
        XML
      end

      let(:model) do
        XmlMapping::ChildNamespaceNil.new(
          {
            element_default_namespace: "Default namespace",
            element_nil_namespace: "No namespace",
            element_new_namespace: "New namespace",
          },
        )
      end

      it "expect to apply correct namespaces" do
        expect(model.to_xml).to be_equivalent_to(expected_xml)
      end
    end

    context "with schemaLocation" do
      context "when mixed: false" do
        let(:xml) do
          <<~XML
            <p xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xsi:schemaLocation="http://www.opengis.net/gml/3.2 http://schemas.opengis.net/gml/3.2.1/gml.xsd">
              <p xmlns:xsi="http://another-instance"
                 xsi:schemaLocation="http://www.opengis.net/gml/3.7">
                Some text inside paragraph
              </p>
            </p>
          XML
        end

        it "contain schemaLocation attributes" do
          expect(Paragraph.from_xml(xml).to_xml).to be_equivalent_to(xml)
        end

        it "prints warning if defined explicitly in class" do
          error_regex = /\[Lutaml::Model\] WARN: `schemaLocation` is handled by default\. No need to explecitly define at `xml_mapping_spec.rb:\d+`/

          expect do
            Lutaml::Model::XmlMapping.new.map_attribute("schemaLocation", to: :schema_location)
          end.to output(error_regex).to_stderr
        end
      end

      context "when mixed: true" do
        let(:xml) do
          <<~XML
            <schemaLocationOrdered xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xsi:schemaLocation="http://www.opengis.net/gml/3.2 http://schemas.opengis.net/gml/3.2.1/gml.xsd">
              <schemaLocationOrdered xmlns:xsi="http://another-instance"
                 xsi:schemaLocation="http://www.opengis.net/gml/3.7">
                Some text inside paragraph
              </schemaLocationOrdered>
            </schemaLocationOrdered>
          XML
        end

        it "contain schemaLocation attributes" do
          expect(XmlMapping::SchemaLocationOrdered.from_xml(xml).to_xml).to be_equivalent_to(xml)
        end
      end
    end

    context "with multiple schemaLocations" do
      let(:xml) do
        <<~XML
          <p xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://www.opengis.net/gml/3.2 http://schemas.opengis.net/gml/3.2.1/gml.xsd http://www.w3.org/1999/xlink http://www.w3.org/1999/xlink.xsd">
            <p xmlns:xsi="http://another-instance"
               xsi:schemaLocation="http://www.opengis.net/gml/3.7 http://schemas.opengis.net/gml/3.7.1/gml.xsd http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20070417/gmd/gmd.xsd">
              Some text inside paragraph
            </p>
          </p>
        XML
      end

      it "parses and serializes multiple schemaLocation attributes" do
        parsed = Paragraph.from_xml(xml)
        expect(parsed.schema_location.size).to eq(2)
        expect(parsed.schema_location[0].namespace).to eq("http://www.opengis.net/gml/3.2")
        expect(parsed.schema_location[0].location).to eq("http://schemas.opengis.net/gml/3.2.1/gml.xsd")
        expect(parsed.schema_location[1].namespace).to eq("http://www.w3.org/1999/xlink")
        expect(parsed.schema_location[1].location).to eq("http://www.w3.org/1999/xlink.xsd")

        serialized = parsed.to_xml
        expect(serialized).to be_equivalent_to(xml)
        expect(serialized).to include('xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"')
        expect(serialized).to include('xsi:schemaLocation="http://www.opengis.net/gml/3.2 http://schemas.opengis.net/gml/3.2.1/gml.xsd http://www.w3.org/1999/xlink http://www.w3.org/1999/xlink.xsd"')
      end

      it "handles nested elements with different schemaLocations" do
        parsed = Paragraph.from_xml(xml)
        nested_p = parsed.paragraph

        expect(nested_p).to be_a(Paragraph)
        expect(nested_p.schema_location.size).to eq(2)
        expect(nested_p.schema_location[0].namespace).to eq("http://www.opengis.net/gml/3.7")
        expect(nested_p.schema_location[0].location).to eq("http://schemas.opengis.net/gml/3.7.1/gml.xsd")
        expect(nested_p.schema_location[1].namespace).to eq("http://www.isotc211.org/2005/gmd")
        expect(nested_p.schema_location[1].location).to eq("http://schemas.opengis.net/iso/19139/20070417/gmd/gmd.xsd")

        serialized = parsed.to_xml
        expect(serialized).to include('xmlns:xsi="http://another-instance"')
        expect(serialized).to include('xsi:schemaLocation="http://www.opengis.net/gml/3.7 http://schemas.opengis.net/gml/3.7.1/gml.xsd http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20070417/gmd/gmd.xsd"')
      end

      it "creates XML with multiple schemaLocations" do
        paragraph = Paragraph.new(
          schema_location: Lutaml::Model::SchemaLocation.new(
            schema_location: {
              "http://www.opengis.net/gml/3.2" => "http://schemas.opengis.net/gml/3.2.1/gml.xsd",
              "http://www.w3.org/1999/xlink" => "http://www.w3.org/1999/xlink.xsd",
            },
            prefix: "xsi",
          ),
          paragraph: Paragraph.new(
            schema_location: Lutaml::Model::SchemaLocation.new(
              schema_location: {
                "http://www.opengis.net/gml/3.7" => "http://schemas.opengis.net/gml/3.7.1/gml.xsd",
                "http://www.isotc211.org/2005/gmd" => "http://schemas.opengis.net/iso/19139/20070417/gmd/gmd.xsd",
              },
              prefix: "xsi",
              namespace: "http://another-instance",
            ),
            text: ["Some text inside paragraph"],
          ),
        )

        serialized = paragraph.to_xml
        expect(serialized).to be_equivalent_to(xml)
      end
    end

    context "with raw mapping" do
      let(:input_xml) do
        <<~XML
          <person>
            <name>John Doe</name>
            <address>
              <street>
                <a>N</a>
                <p>adf</p>
              </street>
              <city><a>M</a></city>
            </address>
          </person>
        XML
      end

      let(:expected_street) do
        if Lutaml::Model::Config.xml_adapter == Lutaml::Model::XmlAdapter::OxAdapter
          "<a>N</a>\n<p>adf</p>\n"
        else
          "\n      <a>N</a>\n      <p>adf</p>\n    "
        end
      end

      let(:model) { XmlMapping::Person.from_xml(input_xml) }

      it "expect to contain raw xml" do
        expect(model.address.street).to eq(expected_street)
        expect(model.address.city.strip).to eq("<a>M</a>")
      end
    end

    context "with content mapping" do
      let(:xml_data) { "<i>my text <b>bold</b> is in italics</i>" }
      let(:italic) { Italic.from_xml(xml_data) }

      it "parses the textual content of an XML element" do
        expect(italic.text).to eq(["my text ", " is in italics"])
      end
    end

    context "with p object" do
      describe "convert from xml containing p tag" do
        let(:xml_data) { "<p>my text for paragraph</p>" }
        let(:paragraph) { Paragraph.from_xml(xml_data) }

        it "parses the textual content of an XML element" do
          expect(paragraph.text).to eq("my text for paragraph")
        end
      end

      describe "generate xml with p tag" do
        let(:paragraph) { Paragraph.new(text: "my text for paragraph") }
        let(:expected_xml) { "<p>my text for paragraph</p>" }

        it "converts to xml correctly" do
          expect(paragraph.to_xml.chomp).to eq(expected_xml)
        end
      end
    end

    describe "#deep_dup" do
      let(:orig_mappings) do
        XmlMapping::ToBeDuplicated.mappings_for(:xml)
      end

      let(:dup_mappings) do
        orig_mappings.deep_dup
      end

      it "duplicates root_element" do
        orig_root = orig_mappings.root_element
        dup_root = dup_mappings.root_element

        expect(orig_root).to eq(dup_root)
        expect(orig_root.object_id).not_to eq(dup_root.object_id)
      end

      it "duplicates namespace_uri" do
        orig_namespace_uri = orig_mappings.namespace_uri
        dup_namespace_uri = dup_mappings.namespace_uri

        expect(orig_namespace_uri).to eq(dup_namespace_uri)
        expect(orig_namespace_uri.object_id).not_to eq(dup_namespace_uri.object_id)
      end

      it "duplicates namespace_prefix" do
        orig_namespace_prefix = orig_mappings.namespace_prefix
        dup_namespace_prefix = dup_mappings.namespace_prefix

        expect(orig_namespace_prefix).to eq(dup_namespace_prefix)
        expect(orig_namespace_prefix.object_id).not_to eq(dup_namespace_prefix.object_id)
      end

      context "when duplicating mapping" do
        let(:orig_mapping) { orig_mappings.mappings[0] }
        let(:dup_mapping) { dup_mappings.mappings[0] }

        it "duplicates custom_methods" do
          orig_custom_methods = orig_mapping.custom_methods
          dup_custom_methods = dup_mapping.custom_methods

          expect(orig_custom_methods).to eq(dup_custom_methods)
          expect(orig_custom_methods.object_id).not_to eq(dup_custom_methods.object_id)
        end

        it "duplicates default_namespace" do
          orig_default_namespace = orig_mapping.default_namespace
          dup_default_namespace = dup_mapping.default_namespace

          expect(orig_default_namespace).to eq(dup_default_namespace)
          expect(orig_default_namespace.object_id).not_to eq(dup_default_namespace.object_id)
        end

        it "duplicates delegate" do
          # `delegate` is symbol which are constant so object_id will be same
          expect(orig_mapping.delegate).to eq(dup_mapping.delegate)
        end

        it "duplicates mixed_content" do
          # boolean value is constant so object_id will be same
          expect(orig_mapping.mixed_content).to eq(dup_mapping.mixed_content)
        end

        it "duplicates name" do
          orig_name = orig_mapping.name
          dup_name = dup_mapping.name

          expect(orig_name).to eq(dup_name)
          expect(orig_name.object_id).not_to eq(dup_name.object_id)
        end

        it "duplicates namespace" do
          orig_namespace = orig_mapping.namespace
          dup_namespace = dup_mapping.namespace

          expect(orig_namespace).to eq(dup_namespace)
          expect(orig_namespace.object_id).not_to eq(dup_namespace.object_id)
        end

        it "duplicates namespace_set" do
          # boolean value is constant so object_id will be same
          expect(orig_mapping.namespace_set?).to eq(dup_mapping.namespace_set?)
        end

        it "duplicates prefix" do
          orig_prefix = orig_mapping.prefix
          dup_prefix = dup_mapping.prefix

          expect(orig_prefix).to eq(dup_prefix)
          expect(orig_prefix.object_id).not_to eq(dup_prefix.object_id)
        end

        it "duplicates prefix_set" do
          # boolean value is constant so object_id will be same
          expect(orig_mapping.prefix_set?).to eq(dup_mapping.prefix_set?)
        end

        it "duplicates render_nil" do
          # boolean value is constant so object_id will be same
          expect(orig_mapping.render_nil?).to eq(dup_mapping.render_nil?)
        end

        it "duplicates to" do
          # `to` is symbol which are constant so object_id will be same
          expect(orig_mapping.to).to eq(dup_mapping.to)
        end
      end
    end

    describe "#map_all" do
      context "when map_all is defined before any other mapping" do
        it "raise error when for map_element with map_all" do
          expect do
            XmlMapping::WithMapAll.xml do
              map_element "ele", to: :ele
            end
          end.to raise_error(
            StandardError,
            "map_element is not allowed, only map_attribute is allowed with map_all",
          )
        end

        it "raise error when for map_content with map_all" do
          expect do
            XmlMapping::WithMapAll.xml do
              map_content to: :text
            end
          end.to raise_error(
            StandardError,
            "map_content is not allowed, only map_attribute is allowed with map_all",
          )
        end

        it "does not raise error for map_attribute with map_all" do
          expect do
            XmlMapping::WithMapAll.xml do
              map_attribute "attr", to: :attr
            end
          end.not_to raise_error
        end
      end

      context "when map_all is defined after other mappings" do
        let(:error_message) { "map_all is not allowed with other mappings" }

        it "raise error when for map_element with map_all" do
          expect do
            XmlMapping::WithoutMapAll.xml do
              map_all to: :all_content
            end
          end.to raise_error(StandardError, error_message)
        end
      end

      context "with custom methods" do
        let(:inner_xml) do
          "Str<sub>2</sub>text<sup>1</sup>123"
        end

        let(:xml) do
          "<MapAllWithCustomMethod>#{inner_xml}</MapAllWithCustomMethod>"
        end

        let(:parsed) do
          XmlMapping::MapAllWithCustomMethod.from_xml(xml)
        end

        it "uses custom method when parsing XML" do
          expect(parsed.all_content).to eq("<div>#{inner_xml}</div>")
        end

        it "generates correct XML" do
          expect(parsed.to_xml.chomp).to be_equivalent_to(xml)
        end
      end

      it "maps all the content including tags" do
        inner_xml = "Str<sub>2</sub>text<sup>1</sup>123"
        xml = "<WithMapAll>#{inner_xml}</WithMapAll>"

        parsed = XmlMapping::WithMapAll.from_xml(xml)

        expect(parsed.all_content).to eq(inner_xml)
      end

      it "round-trips xml" do
        xml = "<WithMapAll>Str<sub>2</sub>text<sup>1</sup>123</WithMapAll>"

        expect(XmlMapping::WithMapAll.from_xml(xml).to_xml.chomp).to eq(xml)
      end

      context "when nested content has map_all" do
        let(:description) do
          <<~DESCRIPTION
            I'm a <b>web developer</b> with <strong>years</strong> of <i>experience</i> in many programing languages.
          DESCRIPTION
        end

        let(:expected_description) do
          <<~DESCRIPTION
            I'm a <b>web developer</b> with <strong>years</strong> of <i>experience</i> in many programing languages.
          DESCRIPTION
        end

        let(:xml) do
          <<~XML
            <WithNestedMapAll age="23">
              <name>John Doe</name>
              <description>
                #{description}
              </description>
            </WithNestedMapAll>
          XML
        end

        let(:expected_xml) do
          <<~XML
            <WithNestedMapAll age="23">
              <name>John Doe</name>
              <description>
                #{expected_description}
              </description>
            </WithNestedMapAll>
          XML
        end

        let(:parsed) do
          XmlMapping::WithNestedMapAll.from_xml(xml)
        end

        it "maps description correctly" do
          expect(parsed.description.all_content.strip).to eq(description.strip)
        end

        it "maps name correctly" do
          expect(parsed.name).to eq("John Doe")
        end

        it "maps age correctly" do
          expect(parsed.age).to eq(23)
        end

        it "round-trips xml" do
          expect(parsed.to_xml).to be_equivalent_to(expected_xml)
        end
      end

      context "when special char used in content with map all" do
        let(:xml) do
          <<~XML
            <SpecialCharContentWithMapAll>
              B <p>R&#x0026;C</p>
              C <p>J&#8212;C</p>
              O <p>A &amp; B </p>
              F <p>Z &#x00A9; </p>
            </SpecialCharContentWithMapAll>
          XML
        end

        let(:expected_nokogiri_xml) do
          <<~XML.strip
            <SpecialCharContentWithMapAll>
              B <p>R&amp;C</p>
              C <p>J—C</p>
              O <p>A &amp; B </p>
              F <p>Z © </p>
            </SpecialCharContentWithMapAll>
          XML
        end

        let(:expected_ox_xml) do
          "<SpecialCharContentWithMapAll> " \
            "B <p>R&amp;C</p> " \
            "C <p>J—C</p> " \
            "O <p>A &amp; B </p> " \
            "F <p>Z © </p>" \
            "</SpecialCharContentWithMapAll>\n"
        end

        it "round-trips xml" do
          expected_xml = adapter_class.type == "ox" ? expected_ox_xml : expected_nokogiri_xml
          expect(XmlMapping::SpecialCharContentWithMapAll.from_xml(xml).to_xml).to eq(expected_xml)
        end
      end

      context "when mixed content is true and child is content_mapping" do
        let(:xml) do
          <<~XML
            <xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
              <xsd:documentation>asdf</xsd:documentation>
            </xsd:schema>
          XML
        end

        it "round-trips xml" do
          expect(XmlMapping::Schema.from_xml(xml).to_xml).to be_equivalent_to(xml)
        end
      end
    end
  end

  describe Lutaml::Model::XmlAdapter::NokogiriAdapter do
    it_behaves_like "having XML Mappings", described_class
  end

  describe Lutaml::Model::XmlAdapter::OxAdapter do
    it_behaves_like "having XML Mappings", described_class
  end

  describe Lutaml::Model::XmlAdapter::OgaAdapter do
    it_behaves_like "having XML Mappings", described_class
  end
end
