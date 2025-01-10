require "spec_helper"
require "lutaml/model/xml_adapter/nokogiri_adapter"
require "lutaml/model/xml_adapter/ox_adapter"
require "lutaml/model/xml_adapter/oga_adapter"
require "lutaml/model"

RSpec.shared_context "XML namespace models" do
  class TestModelNoPrefix < Lutaml::Model::Serializable
    attribute :name, :string

    xml do
      root "test"
      namespace "http://example.com/test", "test"
      map_element "name", to: :name
    end
  end

  class TestModelWithPrefix < Lutaml::Model::Serializable
    attribute :name, :string

    xml do
      root "test"
      namespace "http://example.com/test", "test"
      map_element "name", to: :name
    end
  end

  class SamplePrefixedNamespacedModel < Lutaml::Model::Serializable
    attribute :id, :string
    attribute :lang, :string
    attribute :name, :string, default: -> { "Anonymous" }
    attribute :age, :integer, default: -> { 18 }

    xml do
      root "SamplePrefixedNamespacedModel"
      namespace "http://example.com/foo", "foo"

      map_attribute "id", to: :id
      map_attribute "lang", to: :lang,
                            prefix: "xml",
                            namespace: "http://example.com/xml"

      map_element "Name", to: :name, prefix: "bar", namespace: "http://example.com/bar"
      map_element "Age", to: :age, prefix: "baz", namespace: "http://example.com/baz"
    end
  end

  class NamespaceNilPrefixedNamespaced < Lutaml::Model::Serializable
    attribute :namespace_model, SamplePrefixedNamespacedModel

    xml do
      root "NamespaceNil"
      map_element "SamplePrefixedNamespacedModel", to: :namespace_model,
                                                   namespace: nil,
                                                   prefix: nil
    end
  end

  class SampleDefaultNamespacedModel < Lutaml::Model::Serializable
    attribute :id, :string
    attribute :lang, :string
    attribute :name, :string, default: -> { "Anonymous" }
    attribute :age, :integer, default: -> { 18 }

    xml do
      root "SampleDefaultNamespacedModel"
      namespace "http://example.com/foo"

      map_attribute "id", to: :id
      map_attribute "lang", to: :lang,
                            prefix: "xml",
                            namespace: "http://example.com/xml"

      map_element "Name", to: :name, prefix: "bar", namespace: "http://example.com/bar"
      map_element "Age", to: :age, prefix: "baz", namespace: "http://example.com/baz"
    end
  end

  class NamespaceNilDefaultNamespaced < Lutaml::Model::Serializable
    attribute :namespace_model, SampleDefaultNamespacedModel

    xml do
      root "NamespaceNil"
      map_element "SampleDefaultNamespacedModel", to: :namespace_model,
                                                  namespace: nil,
                                                  prefix: nil
    end
  end

  class Body < Lutaml::Model::Serializable
    attribute :paragraph, :string

    xml do
      map_element "p", to: :paragraph
    end
  end

  class Element < Lutaml::Model::Serializable
    attribute :text, :string
    xml do
      root "test-element"
      namespace "http://www.test.com/schemas/test/1.0/", "test"
      map_content to: :text
    end
  end

  class Front < Lutaml::Model::Serializable
    attribute :test_element, Element

    xml do
      namespace "http://www.test.com/schemas/test/1.0/", "test"
      map_element "test-element", to: :test_element
    end
  end

  class Article < Lutaml::Model::Serializable
    attribute :front, Front
    attribute :body, Body

    xml do
      root "article"
      map_element "front", to: :front, prefix: "test", namespace: "http://www.test.com/schemas/test/1.0/"
      map_element "body", to: :body
    end
  end
end

RSpec.shared_examples "XML serialization with namespace" do |model_class, xml_string|
  it "serializes to XML" do
    model = model_class.new(name: "Test Name")
    expect(model.to_xml).to be_equivalent_to(xml_string)
  end

  it "deserializes from XML" do
    model = model_class.from_xml(xml_string)
    expect(model.name).to eq("Test Name")
  end
end

RSpec.shared_examples "an XML namespace parser" do |adapter_class|
  include_context "XML namespace models"

  around do |example|
    old_adapter = Lutaml::Model::Config.xml_adapter
    Lutaml::Model::Config.xml_adapter = adapter_class
    example.run
  ensure
    Lutaml::Model::Config.xml_adapter = old_adapter
  end

  context "with no prefix" do
    include_examples "XML serialization with namespace",
                     TestModelNoPrefix,
                     '<test xmlns="http://example.com/test"><name>Test Name</name></test>'
  end

  context "with prefix" do
    include_examples "XML serialization with namespace",
                     TestModelWithPrefix,
                     '<test:test xmlns:test="http://example.com/test"><test:name>Test Name</test:name></test:test>'
  end

  context "with prefixed namespace" do
    let(:attributes) { { name: "John Doe", age: 30 } }
    let(:model) { SamplePrefixedNamespacedModel.new(attributes) }

    it "serializes to XML" do
      expected_xml = <<~XML
        <foo:SamplePrefixedNamespacedModel xmlns:foo="http://example.com/foo" xmlns:bar="http://example.com/bar" xmlns:baz="http://example.com/baz">
          <bar:Name>John Doe</bar:Name>
          <baz:Age>30</baz:Age>
        </foo:SamplePrefixedNamespacedModel>
      XML

      expect(model.to_xml).to be_equivalent_to(expected_xml)
    end

    it "deserializes from XML" do
      xml = <<~XML
        <foo:SamplePrefixedNamespacedModel xmlns:foo="http://example.com/foo" xmlns:bar="http://example.com/bar" xmlns:baz="http://example.com/baz">
          <bar:Name>John Doe</bar:Name>
          <baz:Age>30</baz:Age>
        </foo:SamplePrefixedNamespacedModel>
      XML

      new_model = SamplePrefixedNamespacedModel.from_xml(xml)
      expect(new_model.name).to eq("John Doe")
      expect(new_model.age).to eq(30)
    end

    it "round-trips if namespace is set" do
      xml = <<~XML
        <foo:SamplePrefixedNamespacedModel xml:lang="en" xmlns:foo="http://example.com/foo" xmlns:bar="http://example.com/bar" xmlns:baz="http://example.com/baz">
          <bar:Name>John Doe</bar:Name>
          <baz:Age>30</baz:Age>
        </foo:SamplePrefixedNamespacedModel>
      XML

      doc = SamplePrefixedNamespacedModel.from_xml(xml)
      generated_xml = doc.to_xml
      expect(generated_xml).to be_equivalent_to(xml)
    end

    it "round-trips if namespace is set to nil in parent" do
      xml = <<~XML
        <NamespaceNil xmlns:foo="http://example.com/foo" xmlns:bar="http://example.com/bar" xmlns:baz="http://example.com/baz">
          <SamplePrefixedNamespacedModel xml:lang="en">
            <bar:Name>John Doe</bar:Name>
            <baz:Age>30</baz:Age>
          </SamplePrefixedNamespacedModel>
        </NamespaceNil>
      XML

      doc = NamespaceNilPrefixedNamespaced.from_xml(xml)
      generated_xml = doc.to_xml
      expect(generated_xml).to be_equivalent_to(xml)
    end
  end

  context "with default namespace" do
    let(:attributes) { { name: "Jane Smith", age: 25 } }
    let(:model) { SampleDefaultNamespacedModel.new(attributes) }

    it "serializes to XML" do
      expected_xml = <<~XML
        <SampleDefaultNamespacedModel xmlns="http://example.com/foo" xmlns:bar="http://example.com/bar" xmlns:baz="http://example.com/baz">
          <bar:Name>Jane Smith</bar:Name>
          <baz:Age>25</baz:Age>
        </SampleDefaultNamespacedModel>
      XML

      expect(model.to_xml).to be_equivalent_to(expected_xml)
    end

    it "deserializes from XML" do
      xml = <<~XML
        <SampleDefaultNamespacedModel xmlns="http://example.com/foo" xmlns:bar="http://example.com/bar" xmlns:baz="http://example.com/baz">
          <bar:Name>Jane Smith</bar:Name>
          <baz:Age>25</baz:Age>
        </SampleDefaultNamespacedModel>
      XML

      new_model = SampleDefaultNamespacedModel.from_xml(xml)
      expect(new_model.name).to eq("Jane Smith")
      expect(new_model.age).to eq(25)
    end

    it "round-trips if namespace is set" do
      xml = <<~XML
        <SampleDefaultNamespacedModel xml:lang="en" xmlns="http://example.com/foo" xmlns:bar="http://example.com/bar" xmlns:baz="http://example.com/baz">
          <bar:Name>Jane Smith</bar:Name>
          <baz:Age>25</baz:Age>
        </SampleDefaultNamespacedModel>
      XML

      doc = SampleDefaultNamespacedModel.from_xml(xml)
      generated_xml = doc.to_xml
      expect(generated_xml).to be_equivalent_to(xml)
    end

    it "round-trips if namespace is set to nil in parent" do
      xml = <<~XML
        <NamespaceNil xmlns:bar="http://example.com/bar" xmlns:baz="http://example.com/baz">
          <SampleDefaultNamespacedModel xml:lang="en">
            <bar:Name>Jane Smith</bar:Name>
            <baz:Age>25</baz:Age>
          </SampleDefaultNamespacedModel>
        </NamespaceNil>
      XML

      doc = NamespaceNilDefaultNamespaced.from_xml(xml)
      generated_xml = doc.to_xml
      expect(generated_xml).to be_equivalent_to(xml)
    end
  end

  context "when custom namespace is used" do
    let(:xml_input) do
      <<~XML
        <article xmlns:test="http://www.test.com/schemas/test/1.0/">
          <test:front>
            <test:test-element>Text Here</test:test-element>
          </test:front>
          <body>
            <p>This is a paragraph</p>
          </body>
        </article>
      XML
    end

    describe "XML serialization" do
      it "correctly deserializes from XML" do
        article = Article.from_xml(xml_input)
        expect(article.body.paragraph).to eq("This is a paragraph")
      end

      it "round-trips XML" do
        article = Article.from_xml(xml_input)
        output_xml = article.to_xml(pretty: true)

        expect(output_xml).to be_equivalent_to(xml_input)
      end
    end
  end
end

RSpec.describe Lutaml::Model::XmlAdapter::NokogiriAdapter do
  it_behaves_like "an XML namespace parser", described_class
end

RSpec.describe Lutaml::Model::XmlAdapter::OxAdapter do
  it_behaves_like "an XML namespace parser", described_class
end

RSpec.describe Lutaml::Model::XmlAdapter::OgaAdapter do
  it_behaves_like "an XML namespace parser", described_class
end
