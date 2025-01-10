# spec/lutaml/model/ordered_content_spec.rb

require "spec_helper"
require "lutaml/model"
require "lutaml/model/xml_adapter/nokogiri_adapter"
require "lutaml/model/xml_adapter/ox_adapter"
require "lutaml/model/xml_adapter/oga_adapter"
require_relative "../../fixtures/sample_model"

module OrderedContentSpec
  class RootOrderedContent < Lutaml::Model::Serializable
    attribute :id, :string
    attribute :bold, :string, collection: true
    attribute :italic, :string, collection: true
    attribute :underline, :string
    attribute :content, :string

    xml do
      root "RootOrderedContent", ordered: true
      map_attribute :id, to: :id
      map_element :bold, to: :bold
      map_element :italic, to: :italic
      map_element :underline, to: :underline
      map_content to: :content
    end
  end
end

RSpec.describe "OrderedContent" do
  shared_examples "ordered content behavior" do |adapter_class|
    around do |example|
      old_adapter = Lutaml::Model::Config.xml_adapter
      Lutaml::Model::Config.xml_adapter = adapter_class
      example.run
    ensure
      Lutaml::Model::Config.xml_adapter = old_adapter
    end

    context "when ordered: true is set at root" do
      let(:xml) do
        <<~XML
          <RootOrderedContent id="123">
            The Earth's Moon rings like a <bold>bell</bold> when struck by
            meteroids. Distanced from the Earth by <italic>384,400 km</italic>,
            its surface is covered in <underline>craters</underline>.
            Ain't that <bold>cool</bold>?
          </RootOrderedContent>
        XML
      end

      let(:expected_xml) do
        <<~XML
          <RootOrderedContent id="123">
            <bold>bell</bold>
            <italic>384,400 km</italic>
            <underline>craters</underline>
            <bold>cool</bold>
            The Earth's Moon rings like a  when struck by
            meteroids. Distanced from the Earth by ,
            its surface is covered in . Ain't that ?
          </RootOrderedContent>
        XML
      end

      it "deserializes and serializes ordered content correctly" do
        serialized = OrderedContentSpec::RootOrderedContent.from_xml(xml).to_xml
        expect(serialized).to be_equivalent_to(expected_xml)
      end
    end
  end

  describe Lutaml::Model::XmlAdapter::NokogiriAdapter do
    it_behaves_like "ordered content behavior", described_class
  end

  describe Lutaml::Model::XmlAdapter::OxAdapter do
    it_behaves_like "ordered content behavior", described_class
  end

  describe Lutaml::Model::XmlAdapter::OgaAdapter do
    it_behaves_like "ordered content behavior", described_class
  end
end
