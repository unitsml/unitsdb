require "spec_helper"
require "nokogiri"
require_relative "../../../../lib/lutaml/model/xml_adapter/nokogiri_adapter"

RSpec.describe Lutaml::Model::XmlAdapter::NokogiriAdapter do
  let(:xml_string) do
    <<-XML
      <root xmlns="http://example.com/default" xmlns:prefix="http://example.com/prefixed">
        <prefix:child attr="value" prefix:attr1="prefixed_value">Text</prefix:child>
      </root>
    XML
  end

  let(:document) { described_class.parse(xml_string) }

  context "when parsing XML with namespaces" do
    let(:child) { document.root.children[1] }

    it "parses the root element with default namespace" do
      expect(document.root.name).to eq("root")
      expect(document.root.namespace.uri).to eq("http://example.com/default")
      expect(document.root.namespace.prefix).to be_nil
    end

    it "parses child element with prefixed namespace" do
      expect(child.name).to eq("prefix:child")
      expect(child.namespace.uri).to eq("http://example.com/prefixed")
      expect(child.namespace.prefix).to eq("prefix")
    end

    it "parses attributes with and without namespaces" do
      expect(child.attributes["attr"].value).to eq("value")
      expect(child.attributes["attr"].namespace).to be_nil
      expect(child.attributes["prefix:attr1"].value).to eq("prefixed_value")
      expect(child.attributes["prefix:attr1"].namespace).to eq("http://example.com/prefixed")
      expect(child.attributes["prefix:attr1"].namespace_prefix).to eq("prefix")
    end
  end

  context "when generating XML with namespaces" do
    it "generates XML with namespaces correctly" do
      xml_output = document.to_xml
      parsed_output = Nokogiri::XML(xml_output)

      root = parsed_output.root
      expect(root.name).to eq("root")
      expect(root.namespace.href).to eq("http://example.com/default")

      child = root.children[1]
      expect(child.name).to eq("child")
      expect(child.namespace.href).to eq("http://example.com/prefixed")
      expect(child.attributes["attr"].value).to eq("value")
      expect(child.attributes["attr1"].value).to eq("prefixed_value")
    end
  end
end
