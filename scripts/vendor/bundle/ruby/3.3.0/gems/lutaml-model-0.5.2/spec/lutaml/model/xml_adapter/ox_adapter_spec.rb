require "spec_helper"
require "ox"
require_relative "../../../../lib/lutaml/model/xml_adapter/ox_adapter"

RSpec.describe Lutaml::Model::XmlAdapter::OxAdapter do
  let(:xml_string) do
    <<-XML
      <root xmlns="http://example.com/default" xmlns:prefix="http://example.com/prefixed">
        <prefix:child attr="value" prefix:attr="prefixed_value">Text</prefix:child>
        <!-- just-a-comment -->
      </root>
    XML
  end

  let(:document) { described_class.parse(xml_string) }

  context "parsing XML with namespaces" do
    it "parses the root element with default namespace" do
      expect(document.root.name).to eq("root")
      expect(document.root.namespace.uri).to eq("http://example.com/default")
      expect(document.root.namespace.prefix).to be_nil
    end

    it "parses child element with prefixed namespace" do
      child = document.root.children.first
      expect(child.name).to eq("prefix:child")
      expect(child.namespace.uri).to eq("http://example.com/prefixed")
      expect(child.namespace.prefix).to eq("prefix")
    end

    it "parses comment" do
      expect(document.root.nodes.last.text).to eq("just-a-comment")
    end

    it "parses attributes with and without namespaces" do
      child = document.root.children.first
      expect(child.attributes["attr"].value).to eq("value")
      expect(child.attributes["attr"].namespace).to be_nil
      expect(child.attributes["prefix:attr"].value).to eq("prefixed_value")
      expect(child.attributes["prefix:attr"].namespace).to eq("http://example.com/prefixed")
      expect(child.attributes["prefix:attr"].namespace_prefix).to eq("prefix")
    end
  end

  context "generating XML with namespaces" do
    it "generates XML with namespaces correctly" do
      xml_output = document.to_xml
      parsed_output = Ox.parse(xml_output)

      root = parsed_output
      expect(root.name).to eq("root")
      expect(root.attributes[:xmlns]).to eq("http://example.com/default")
      expect(root.attributes[:"xmlns:prefix"]).to eq("http://example.com/prefixed")

      child = root.nodes.first
      expect(child.name).to eq("prefix:child")
      expect(child.attributes[:attr]).to eq("value")
      expect(child.attributes[:"prefix:attr"]).to eq("prefixed_value")
    end
  end
end
