# spec/lutaml/model/mixed_content_spec.rb

require "spec_helper"
require "lutaml/model"
require "lutaml/model/xml_adapter/nokogiri_adapter"
require "lutaml/model/xml_adapter/ox_adapter"
require "lutaml/model/xml_adapter/oga_adapter"
require_relative "../../fixtures/sample_model"

module MixedContentSpec
  class PlanetaryBody < Lutaml::Model::Serializable
    attribute :name, :string
    attribute :distance_from_earth, :integer
    xml do
      root "PlanetaryBody"
      map_element "Name", to: :name
      map_element "DistanceFromEarth", to: :distance_from_earth
    end
  end

  class Source < Lutaml::Model::Serializable
    attribute :content, :string

    xml do
      root "source"
      map_content to: :content
    end
  end

  class ElementCitation < Lutaml::Model::Serializable
    attribute :source, Source

    xml do
      root "element-citation"
      map_element "source", to: :source
    end
  end

  class Ref < Lutaml::Model::Serializable
    attribute :element_citation, ElementCitation

    xml do
      root "ref"
      map_element "element-citation", to: :element_citation
    end
  end

  class RefList < Lutaml::Model::Serializable
    attribute :ref, Ref

    xml do
      root "ref-list"
      map_element "ref", to: :ref
    end
  end

  class Back < Lutaml::Model::Serializable
    attribute :ref_list, RefList

    xml do
      root "back"
      map_element "ref-list", to: :ref_list
    end
  end

  class Article < Lutaml::Model::Serializable
    attribute :back, Back

    xml do
      root "article"
      map_element "back", to: :back
    end
  end

  class Latin < Lutaml::Model::Serializable
    attribute :the, :string
    attribute :from, :string
    attribute :heading, :string

    xml do
      root "note"
      map_element "to", to: :the
      map_element "from", to: :from
      map_element "heading", to: :heading
    end
  end

  class Shift < Lutaml::Model::Serializable
    attribute :field, :string, collection: true

    xml do
      root "root"
      map_element "FieldName", to: :field
    end
  end

  class SpecialCharContentWithMixedTrue < Lutaml::Model::Serializable
    attribute :content, :string

    xml do
      root "SpecialCharContentWithMixedTrue", mixed: true
      map_content to: :content
    end
  end

  class SpecialCharContentWithRawAndMixedOption < Lutaml::Model::Serializable
    attribute :special, :string, raw: true

    xml do
      root "SpecialCharContentWithRawOptionAndMixedOption", mixed: true
      map_element :special, to: :special
    end
  end

  class RootMixedContent < Lutaml::Model::Serializable
    attribute :id, :string
    attribute :bold, :string, collection: true
    attribute :italic, :string, collection: true
    attribute :underline, :string
    attribute :content, :string

    xml do
      root "RootMixedContent", mixed: true
      map_attribute :id, to: :id
      map_element :bold, to: :bold
      map_element :italic, to: :italic
      map_element :underline, to: :underline
      map_content to: :content
    end
  end

  class RootMixedContentWithModel < Lutaml::Model::Serializable
    attribute :id, :string
    attribute :bold, :string, collection: true
    attribute :italic, :string, collection: true
    attribute :underline, :string
    attribute :planetary_body, PlanetaryBody
    attribute :content, :string

    xml do
      root "RootMixedContentWithModel", mixed: true
      map_content to: :content
      map_attribute :id, to: :id
      map_element :bold, to: :bold
      map_element :italic, to: :italic
      map_element :underline, to: :underline
      map_element "PlanetaryBody", to: :planetary_body
    end
  end

  class RootMixedContentNested < Lutaml::Model::Serializable
    attribute :id, :string
    attribute :text, :string
    attribute :content, RootMixedContent
    attribute :sup, :string, collection: true
    attribute :sub, :string, collection: true

    xml do
      root "RootMixedContentNested", mixed: true
      map_content to: :text
      map_attribute :id, to: :id
      map_element :sup, to: :sup
      map_element :sub, to: :sub
      map_element "MixedContent", to: :content
    end
  end

  class RootMixedContentNestedWithModel < Lutaml::Model::Serializable
    attribute :id, :string
    attribute :text, :string
    attribute :content, RootMixedContentWithModel
    attribute :sup, :string, collection: true
    attribute :sub, :string, collection: true

    xml do
      root "RootMixedContentNestedWithModel", mixed: true

      map_content to: :text
      map_attribute :id, to: :id
      map_element :sup, to: :sup
      map_element :sub, to: :sub
      map_element "MixedContentWithModel", to: :content
    end
  end

  class TextualSupport < Lutaml::Model::Serializable
    attribute :value, :string

    xml do
      root "TextualSupport"

      map_element :value, to: :value
    end
  end

  class HexCode < Lutaml::Model::Serializable
    attribute :content, :string

    xml do
      root "HexCode"
      map_content to: :content
    end
  end
end

RSpec.describe "MixedContent" do
  shared_examples "mixed content behavior" do |adapter_class|
    around do |example|
      old_adapter = Lutaml::Model::Config.xml_adapter
      Lutaml::Model::Config.xml_adapter = adapter_class
      example.run
    ensure
      Lutaml::Model::Config.xml_adapter = old_adapter
    end

    context "when mixed: true is set at root" do
      let(:xml) do
        <<~XML
          <RootMixedContent id="123">
            The Earth's Moon rings like a <bold>bell</bold> when struck by
            meteroids. Distanced from the Earth by <italic>384,400 km</italic>,
            its surface is covered in <underline>craters</underline>.
            Ain't that <bold>cool</bold>?
          </RootMixedContent>
        XML
      end

      it "deserializes and serializes mixed content correctly" do
        parsed = MixedContentSpec::RootMixedContent.from_xml(xml)

        expected_content = [
          "\n  The Earth's Moon rings like a ",
          " when struck by\n  meteroids. Distanced from the Earth by ",
          ",\n  its surface is covered in ",
          ".\n  Ain't that ",
          "?\n",
        ]

        expect(parsed.id).to eq("123")
        expect(parsed.bold).to eq(["bell", "cool"])
        expect(parsed.italic).to eq(["384,400 km"])
        expect(parsed.underline).to eq("craters")

        parsed.content.each_with_index do |content, index|
          expected_output = expected_content[index]

          # due to the difference in capturing
          # newlines in ox and nokogiri adapters
          if adapter_class == Lutaml::Model::XmlAdapter::OxAdapter
            expected_output = expected_output.gsub(/\n\s*/, " ")
          end

          expect(content).to eq(expected_output)
        end

        serialized = parsed.to_xml
        expect(serialized).to be_equivalent_to(xml)
      end
    end

    context "when mixed: true is set at root with nested model" do
      let(:xml) do
        <<~XML
          <RootMixedContentWithModel id="123">
            The Earth's Moon rings like a <bold>bell</bold> when struck by
            meteroids. Distanced from the Earth by <italic>384,400 km</italic>,
            its surface is covered in <underline>craters</underline>.
            Ain't that <bold>cool</bold>?
            <PlanetaryBody>
              <Name>Moon</Name>
              <DistanceFromEarth>384400</DistanceFromEarth>
            </PlanetaryBody>
            NOTE: The above model content is to be formatted as a table.
          </RootMixedContentWithModel>
        XML
      end

      it "deserializes and serializes mixed content correctly" do
        parsed = MixedContentSpec::RootMixedContentWithModel.from_xml(xml)

        expected_content = [
          "\n  The Earth's Moon rings like a ",
          " when struck by\n  meteroids. Distanced from the Earth by ",
          ",\n  its surface is covered in ",
          ".\n  Ain't that ",
          "?\n  ",
          "\n  NOTE: The above model content is to be formatted as a table.\n",
        ]

        expect(parsed.id).to eq("123")
        expect(parsed.bold).to eq(["bell", "cool"])
        expect(parsed.italic).to eq(["384,400 km"])
        expect(parsed.underline).to eq("craters")

        parsed.content.each_with_index do |content, index|
          expected_output = expected_content[index]

          # due to the difference in capturing
          # newlines in ox and nokogiri adapters
          if adapter_class == Lutaml::Model::XmlAdapter::OxAdapter
            expected_output = expected_output.gsub(/\n\s*/, " ")
          end

          expect(content).to eq(expected_output)
        end

        expect(parsed.planetary_body.name).to eq("Moon")
        expect(parsed.planetary_body.distance_from_earth).to eq(384400)

        serialized = parsed.to_xml
        expect(serialized).to be_equivalent_to(xml)
      end
    end

    context "when mixed: true is set for nested content" do
      let(:xml) do
        <<~XML
          <RootMixedContentNested id="outer123">
            The following text is about the Moon.
            <MixedContent id="inner456">
              The Earth's Moon rings like a <bold>bell</bold> when struck by
              meteroids. Distanced from the Earth by <italic>384,400 km</italic>,
              its surface is covered in <underline>craters</underline>.
              Ain't that <bold>cool</bold>?
            </MixedContent>
            <sup>1</sup>: The Moon is not a planet.
            <sup>2</sup>: The Moon's atmosphere is mainly composed of helium in the form of He<sub>2</sub>.
          </RootMixedContentNested>
        XML
      end

      it "deserializes and serializes mixed content correctly" do
        parsed = MixedContentSpec::RootMixedContentNested.from_xml(xml)

        expected_content = [
          "\n    The Earth's Moon rings like a ",
          " when struck by\n    meteroids. Distanced from the Earth by ",
          ",\n    its surface is covered in ",
          ".\n    Ain't that ",
          "?\n  ",
        ]

        expect(parsed.id).to eq("outer123")
        expect(parsed.sup).to eq(["1", "2"])
        expect(parsed.sub).to eq(["2"])
        expect(parsed.content.id).to eq("inner456")
        expect(parsed.content.bold).to eq(["bell", "cool"])
        expect(parsed.content.italic).to eq(["384,400 km"])
        expect(parsed.content.underline).to eq("craters")

        parsed.content.content.each_with_index do |content, index|
          expected_output = expected_content[index]

          # due to the difference in capturing
          # newlines in ox and nokogiri adapters
          if adapter_class == Lutaml::Model::XmlAdapter::OxAdapter
            expected_output = expected_output.gsub(/\n\s*/, " ")
          end

          expect(content).to eq(expected_output)
        end

        serialized = parsed.to_xml
        expect(serialized).to be_equivalent_to(xml)
      end
    end

    context "when mixed: true is set for nested content with model" do
      let(:xml) do
        <<~XML
          <RootMixedContentNestedWithModel id="outer123">
            The following text is about the Moon.
            <MixedContentWithModel id="inner456">
              The Earth's Moon rings like a <bold>bell</bold> when struck by
              meteroids. Distanced from the Earth by <italic>384,400 km</italic>,
              its surface is covered in <underline>craters</underline>.
              Ain't that <bold>cool</bold>?
              <PlanetaryBody>
                <Name>Moon</Name>
                <DistanceFromEarth>384400</DistanceFromEarth>
              </PlanetaryBody>
              NOTE: The above model content is to be formatted as a table.
            </MixedContentWithModel>
            <sup>1</sup>: The Moon is not a planet.
            <sup>2</sup>: The Moon's atmosphere is mainly composed of helium in the form of He<sub>2</sub>.
          </RootMixedContentNestedWithModel>
        XML
      end

      it "deserializes and serializes mixed content correctly" do
        parsed = MixedContentSpec::RootMixedContentNestedWithModel.from_xml(xml)

        expected_content = [
          "\n    The Earth's Moon rings like a ",
          " when struck by\n    meteroids. Distanced from the Earth by ",
          ",\n    its surface is covered in ",
          ".\n    Ain't that ",
          "?\n    ",
          "\n    NOTE: The above model content is to be formatted as a table.\n  ",
        ]

        expect(parsed.id).to eq("outer123")
        expect(parsed.sup).to eq(["1", "2"])
        expect(parsed.sub).to eq(["2"])
        expect(parsed.content.id).to eq("inner456")
        expect(parsed.content.bold).to eq(["bell", "cool"])
        expect(parsed.content.italic).to eq(["384,400 km"])
        expect(parsed.content.underline).to eq("craters")

        parsed.content.content.each_with_index do |content, index|
          expected_output = expected_content[index]

          # due to the difference in capturing
          # newlines in ox and nokogiri adapters
          if adapter_class == Lutaml::Model::XmlAdapter::OxAdapter
            expected_output = expected_output.gsub(/\n\s*/, " ")
          end

          expect(content).to eq(expected_output)
        end

        expect(parsed.content.planetary_body.name).to eq("Moon")
        expect(parsed.content.planetary_body.distance_from_earth).to eq(384400)

        serialized = parsed.to_xml
        expect(serialized).to be_equivalent_to(xml)
      end
    end

    context "when mixed: true is used with map_element" do
      it "raises an error" do
        expect do
          Class.new(Lutaml::Model::Serializable) do
            attribute :id, :string

            xml do
              root "Invalid"
              map_element :id, to: :id, mixed: true
            end
          end
        end.to raise_error(ArgumentError, /unknown keyword: :mixed/)
      end
    end

    context "when mixed: true is used with map_attribute" do
      it "raises an error" do
        expect do
          Class.new(Lutaml::Model::Serializable) do
            attribute :id, :string

            xml do
              root "Invalid"
              map_attribute :id, to: :id, mixed: true
            end
          end
        end.to raise_error(ArgumentError, /unknown keyword: :mixed/)
      end
    end

    context "when special char used in content with mixed true" do
      let(:xml) do
        <<~XML
          <SpecialCharContentWithMixedTrue>
            Moon&#x0026;Mars Distanced&#x00A9;its &#8212; surface covered &amp; processed
          </SpecialCharContentWithMixedTrue>
        XML
      end

      describe ".from_xml" do
        let(:expected_content) { "Moon&Mars Distanced©its — surface covered & processed" }

        it "deserializes special char mixed content correctly" do
          parsed = MixedContentSpec::SpecialCharContentWithMixedTrue.from_xml(xml)
          expect(parsed.content.strip).to eq(expected_content)
        end
      end

      describe ".to_xml" do
        let(:expected_xml) { "Moon&amp;Mars Distanced©its — surface covered &amp; processed" }

        it "serializes special char mixed content correctly" do
          parsed = MixedContentSpec::SpecialCharContentWithMixedTrue.from_xml(xml)
          serialized = parsed.to_xml(encoding: "UTF-8")

          expect(serialized).to include(expected_xml)
        end
      end
    end

    context "when special char used in content read from xml file" do
      let(:fixture) { File.read(fixture_path("xml/special_char.xml")) }

      describe ".from_xml" do
        it "deserializes special char mixed content correctly" do
          parsed = MixedContentSpec::Article.from_xml(fixture)
          expect(parsed.back.ref_list.ref.element_citation.source.content).to include("R&D")
        end
      end

      describe ".to_xml" do
        it "serializes special char mixed content correctly" do
          parsed = MixedContentSpec::Article.from_xml(fixture)
          serialized = parsed.to_xml

          expect(serialized).to include("R&amp;D")
        end
      end
    end

    context "when special char entities used with raw true" do
      let(:xml) do
        <<~XML
          <SpecialCharContentWithRawAndMixedOption>
            <special>
              B <p>R&#x0026;C</p>
              C <p>J&#8212;C</p>
              O <p>A &amp; B </p>
              F <p>Z &#x00A9;S</p>
            </special>
          </SpecialCharContentWithRawAndMixedOption>
        XML
      end

      describe ".from_xml" do
        let(:expected_nokogiri_content) { "B <p>R&amp;C</p>\n    C <p>J&#x2014;C</p>\n    O <p>A &amp; B </p>\n    F <p>Z &#xA9;S</p>" }
        let(:expected_ox_content) { "B <p>R&amp;C</p>\n C <p>J—C</p>\n O <p>A &amp; B </p>\n F <p>Z ©S</p>" }
        let(:expected_oga_content) { "B <p>R&amp;C</p>\n    C <p>J—C</p>\n    O <p>A &amp; B </p>\n    F <p>Z ©S</p>" }

        it "deserializes special char mixed content correctly" do
          parsed = MixedContentSpec::SpecialCharContentWithRawAndMixedOption.from_xml(xml)
          expected_content = public_send(:"expected_#{adapter_class.type}_content")
          parsed.special.force_encoding("UTF-8") unless adapter_class == Lutaml::Model::XmlAdapter::NokogiriAdapter

          expect(parsed.special.strip).to eq(expected_content)
        end
      end

      describe ".to_xml" do
        let(:expected_nokogiri_xml) do
          <<~XML
            <SpecialCharContentWithRawOptionAndMixedOption><special>
                B &lt;p&gt;R&amp;amp;C&lt;/p&gt;
                C &lt;p&gt;J&amp;#x2014;C&lt;/p&gt;
                O &lt;p&gt;A &amp;amp; B &lt;/p&gt;
                F &lt;p&gt;Z &amp;#xA9;S&lt;/p&gt;
              </special></SpecialCharContentWithRawOptionAndMixedOption>
          XML
        end

        let(:expected_ox_xml) do
          <<~XML
            <SpecialCharContentWithRawOptionAndMixedOption>
              <special> B &lt;p&gt;R&amp;amp;C&lt;/p&gt;
                C &lt;p&gt;J—C&lt;/p&gt;
                O &lt;p&gt;A &amp;amp; B &lt;/p&gt;
                F &lt;p&gt;Z ©S&lt;/p&gt;
              </special>
              </SpecialCharContentWithRawOptionAndMixedOption>
          XML
        end

        let(:expected_oga_xml) do
          <<~XML
            <SpecialCharContentWithRawOptionAndMixedOption>
              <special> B &lt;p&gt;R&amp;C&lt;/p&gt;
                C &lt;p&gt;J—C&lt;/p&gt;
                O &lt;p&gt;A &amp; B &lt;/p&gt;
                F &lt;p&gt;Z ©S&lt;/p&gt;
              </special>
            </SpecialCharContentWithRawOptionAndMixedOption>
          XML
        end

        it "serializes special char mixed content correctly" do
          parsed = MixedContentSpec::SpecialCharContentWithRawAndMixedOption.from_xml(xml)
          serialized = parsed.to_xml

          expect(serialized).to be_equivalent_to(send(:"expected_#{adapter_class.type}_xml"))
        end
      end
    end

    context "when special char used with raw true, remove & if entity not provided" do
      let(:xml) do
        <<~XML
          <SpecialCharContentWithRawAndMixedOption>
            <special>
              B <p>R&C</p>
            </special>
          </SpecialCharContentWithRawAndMixedOption>
        XML
      end

      describe ".from_xml" do
        let(:expected_nokogiri_content) { "B <p>R</p>" }
        let(:expected_ox_content) { "B <p>R&amp;C</p>" }

        it "deserializes special char mixed content correctly" do
          parsed = MixedContentSpec::SpecialCharContentWithRawAndMixedOption.from_xml(xml)

          expected_output = adapter_class == Lutaml::Model::XmlAdapter::NokogiriAdapter ? expected_nokogiri_content : expected_ox_content
          expect(parsed.special.strip).to eq(expected_output)
        end
      end

      describe ".to_xml" do
        let(:expected_nokogiri_xml) { "B &lt;p&gt;R&lt;/p&gt;" }
        let(:expected_oga_xml) { "B &lt;p&gt;R&amp;C&lt;/p&gt;" }
        let(:expected_ox_xml) { "B &lt;p&gt;R&amp;amp;C&lt;/p&gt;" }

        it "serializes special char mixed content correctly" do
          parsed = MixedContentSpec::SpecialCharContentWithRawAndMixedOption.from_xml(xml)
          serialized = parsed.to_xml

          expect(serialized).to include(send(:"expected_#{adapter_class.type}_xml"))
        end
      end
    end

    context "when special char used as full entities" do
      let(:xml) do
        <<~XML
          <TextualSupport>
            <value>&lt;computer security&gt; type of operation specified by an access right</value>
          </TextualSupport>
        XML
      end

      describe ".from_xml" do
        let(:expected_content) { "<computer security> type of operation specified by an access right" }

        it "deserializes special char mixed content correctly" do
          parsed = MixedContentSpec::TextualSupport.from_xml(xml)

          expect(parsed.value).to eq(expected_content)
        end
      end

      describe ".to_xml" do
        let(:expected_xml) { "<TextualSupport>\n  <value>&lt;computer security&gt; type of operation specified by an access right</value>\n</TextualSupport>" }
        let(:expected_oga_xml) { "<TextualSupport><value>&lt;computer security&gt; type of operation specified by an access right</value></TextualSupport>" }

        it "serializes special char mixed content correctly" do
          parsed = MixedContentSpec::TextualSupport.from_xml(xml)
          serialized = parsed.to_xml
          expected = adapter_class.type == "oga" ? expected_oga_xml : expected_xml
          expect(serialized.strip).to include(expected)
        end
      end
    end

    context "when special char used as full entities, it persist as entities if no encoding provided" do
      let(:xml) do
        <<~XML
          <HexCode>
            &#x2211;computer security&#x220F; type of &#x200B; operation specified &#xB5; by an access right
          </HexCode>
        XML
      end

      describe ".from_xml" do
        let(:expected_content) { "∑computer security∏ type of ​ operation specified µ by an access right" }

        it "deserializes special char mixed content correctly" do
          parsed = MixedContentSpec::HexCode.from_xml(xml)

          expect(parsed.content.strip).to eq(expected_content)
        end
      end

      describe ".to_xml" do
        context "when default encoding xml" do
          let(:expected_default_encoding_xml) { "∑computer security∏ type of ​ operation specified µ by an access right" }

          it "serializes special char mixed content correctly with default encoding: UTF-8" do
            parsed = MixedContentSpec::HexCode.from_xml(xml)
            serialized = parsed.to_xml

            expect(serialized.strip).to include(expected_default_encoding_xml)
          end
        end

        context "when encoding: nil xml" do
          let(:expected_encoding_nil_nokogiri_xml) { "&#x2211;computer security&#x220F; type of &#x200B; operation specified &#xB5; by an access right" }
          let(:expected_encoding_nil_ox_xml) { "∑computer security∏ type of ​ operation specified µ by an access right" }

          it "serializes special char mixed content correctly with encoding: nil to get hexcode" do
            parsed = MixedContentSpec::HexCode.from_xml(xml)
            serialized = parsed.to_xml(encoding: nil)

            expected_output = if adapter_class == Lutaml::Model::XmlAdapter::NokogiriAdapter
                                expected_encoding_nil_nokogiri_xml
                              else
                                expected_encoding_nil_ox_xml
                              end

            expect(serialized.strip).to include(expected_output)
          end
        end
      end
    end

    context "when use encoding in parsing" do
      context "when use SHIFT-JIS encoding" do
        let(:fixture) { File.read(fixture_path("xml/shift_jis.xml"), encoding: "Shift_JIS") }

        describe ".from_xml" do
          it "verifies the encoding of file read" do
            expect(fixture.encoding.to_s).to eq("Shift_JIS")
          end

          it "deserializes SHIFT encoded content correctly with explicit encoding option" do
            parsed = MixedContentSpec::Shift.from_xml(fixture, encoding: "Shift_JIS")

            expected_content = if adapter_class == Lutaml::Model::XmlAdapter::OxAdapter
                                 "\x8E\xE8\x8F\x91\x82\xAB\x89p\x8E\x9A\x82P".force_encoding("Shift_JIS")
                               else
                                 "手書き英字１"
                               end

            expect(parsed.field).to include(expected_content)
          end

          it "deserializes SHIFT encoded content incorrectly without explicit encoding option" do
            parsed = MixedContentSpec::Shift.from_xml(fixture)

            expected_content = if adapter_class == Lutaml::Model::XmlAdapter::NokogiriAdapter
                                 "�菑���p���P"
                               elsif adapter_class == Lutaml::Model::XmlAdapter::OgaAdapter
                                 "手書き英字１"
                               else
                                 "\x8E\xE8\x8F\x91\x82\xAB\x89p\x8E\x9A\x82P".force_encoding("UTF-8")
                               end

            expect(parsed.field).to include(expected_content)
          end
        end

        describe ".to_xml" do
          it "serializes SHIFT-JIS encoding content correctly reading from file" do
            parsed = MixedContentSpec::Shift.from_xml(fixture, encoding: "Shift_JIS")
            serialized = parsed.to_xml
            expected = adapter_class.type == "oga" ? fixture.gsub(/\s+/, "") : fixture.strip
            expect(serialized.strip).to eq(expected)
          end

          it "serializes SHIFT encoded content correctly with explicit encoding option both in parsing and deserializing" do
            parsed = MixedContentSpec::Shift.from_xml(fixture, encoding: "Shift_JIS")
            serialized = parsed.to_xml(encoding: "UTF-8")

            expected_xml = if adapter_class == Lutaml::Model::XmlAdapter::OxAdapter
                             "\x8E\xE8\x8F\x91\x82\xAB\x89p\x8E\x9A\x82P".force_encoding("Shift_JIS")
                           else
                             "手書き英字１"
                           end

            expect(parsed.field).to include(expected_xml)
            expect(parsed.encoding).to eq("Shift_JIS")

            expect(serialized).to include("手書き英字１")
            expect(serialized.encoding.to_s).to eq("UTF-8")
          end

          it "serializes SHIFT encoded content correctly with explicit encoding option" do
            parsed = MixedContentSpec::Shift.from_xml(fixture, encoding: "Shift_JIS")
            serialized = parsed.to_xml(encoding: "Shift_JIS")

            expected_xml = if adapter_class == Lutaml::Model::XmlAdapter::OxAdapter
                             "\x8E\xE8\x8F\x91\x82\xAB\x89p\x8E\x9A\x82P".force_encoding("Shift_JIS")
                           else
                             "手書き英字１"
                           end

            expect(parsed.field).to include(expected_xml)
            expect(parsed.encoding).to eq("Shift_JIS")

            expect(serialized).to include("\x8E\xE8\x8F\x91\x82\xAB\x89p\x8E\x9A\x82P".force_encoding("Shift_JIS"))
            expect(serialized.encoding.to_s).to eq("Shift_JIS")
          end

          it "serializes SHIFT encoded content correctly with declaration: true" do
            parsed = MixedContentSpec::Shift.from_xml(fixture, encoding: "Shift_JIS")
            serialized = parsed.to_xml(declaration: true, encoding: "Shift_JIS")

            expected_xml = "<?xml version=\"1.0\" encoding=\"Shift_JIS\"?>\n<root>\n  <FieldName>\x8E\xE8\x8F\x91\x82\xAB\x89p\x8E\x9A\x82P</FieldName>\n  <FieldName>123456</FieldName>\n</root>"

            expect(serialized).to be_equivalent_to(expected_xml)
            expect(serialized.encoding.to_s).to eq("Shift_JIS")
          end

          it "serializes SHIFT-JIS content incorrectly bcz no encoding provided during parsing" do
            parsed = MixedContentSpec::Shift.from_xml(fixture)
            serialized = parsed.to_xml(encoding: "Shift_JIS")
            expected_content = if adapter_class == Lutaml::Model::XmlAdapter::NokogiriAdapter
                                 "<root>\n  <FieldName>&#65533;&#33745;&#65533;&#65533;&#65533;p&#65533;&#65533;&#65533;P</FieldName>\n  <FieldName>123456</FieldName>\n</root>"
                               elsif adapter_class == Lutaml::Model::XmlAdapter::OxAdapter
                                 "<root>\n  <FieldName>\x8E菑\x82\xAB\x89p\x8E\x9A\x82P</FieldName>\n  <FieldName>123456</FieldName>\n</root>\n"
                               else
                                 "<root><FieldName>手書き英字１</FieldName><FieldName>123456</FieldName></root>".encode("Shift_JIS")
                               end
            expect(serialized).to eq(expected_content)
          end

          it "serializes SHIFT-JIS encoding content correctly reading from string" do
            xml = "<root><FieldName>手書き英字１</FieldName><FieldName>123456</FieldName></root>".encode("Shift_JIS")
            parsed = MixedContentSpec::Shift.from_xml(xml, encoding: "Shift_JIS")
            serialized = parsed.to_xml(encoding: "Shift_JIS")

            expect(serialized).to be_equivalent_to(xml)
          end

          it "serializes SHIFT-JIS encoding content correctly" do
            parsed = MixedContentSpec::Shift.from_xml(fixture, encoding: "Shift_JIS")
            serialized = parsed.to_xml(encoding: "Shift_JIS")

            expect(serialized).to be_equivalent_to(fixture)
          end
        end
      end

      context "when use LATIN (ISO-8859-1) encoding" do
        let(:fixture) { File.read(fixture_path("xml/latin_encoding.xml"), encoding: "ISO-8859-1") }

        describe ".from_xml" do
          it "verifies the encoding of file read" do
            expect(fixture.encoding.to_s).to eq("ISO-8859-1")
          end

          it "deserializes latin encoded content correctly" do
            parsed = MixedContentSpec::Latin.from_xml(fixture, encoding: "ISO-8859-1")

            expected_content = if adapter_class == Lutaml::Model::XmlAdapter::OxAdapter
                                 ["M\xFCller".force_encoding("ISO-8859-1"), "Jos\xE9".force_encoding("ISO-8859-1")]
                               else
                                 ["Müller", "José"]
                               end

            expect(parsed.from).to eq(expected_content[0])
            expect(parsed.the).to eq(expected_content[1])
          end

          it "deserializes latin encoded content incorrectly" do
            parsed = MixedContentSpec::Latin.from_xml(fixture)

            expected_content = if adapter_class == Lutaml::Model::XmlAdapter::NokogiriAdapter
                                 ["M�ller", "Jos�"]
                               elsif adapter_class == Lutaml::Model::XmlAdapter::OgaAdapter
                                 ["Müller", "José"]
                               else
                                 ["M\xFCller", "Jos\xE9"]
                               end

            expect(parsed.from).to eq(expected_content[0])
            expect(parsed.the).to eq(expected_content[1])
          end
        end

        describe ".to_xml" do
          it "serializes latin encoded content correctly" do
            parsed = MixedContentSpec::Latin.from_xml(fixture, encoding: "ISO-8859-1")
            serialized = parsed.to_xml
            expected_xml = if adapter_class == Lutaml::Model::XmlAdapter::OgaAdapter
                             "<note><to>Jos\xE9</to><from>M\xFCller</from><heading>Reminder</heading></note>"
                           else
                             "<note>\n  <to>Jos\xE9</to>\n  <from>M\xFCller</from>\n  <heading>Reminder</heading>\n</note>"
                           end
            expect(serialized.strip).to eq(expected_xml.force_encoding("ISO-8859-1"))
          end
        end
      end
    end
  end

  describe Lutaml::Model::XmlAdapter::NokogiriAdapter do
    it_behaves_like "mixed content behavior", described_class

    it "raises error when serializes special char content with false encoding: 'ABC'" do
      parsed = MixedContentSpec::HexCode.from_xml("<HexCode>&#x2211;computer security</HexCode>")

      expect { parsed.to_xml(encoding: "ABC") }.to raise_error(StandardError, "unknown encoding name - ABC")
    end
  end

  describe Lutaml::Model::XmlAdapter::OxAdapter do
    it_behaves_like "mixed content behavior", described_class
  end

  describe Lutaml::Model::XmlAdapter::OgaAdapter do
    it_behaves_like "mixed content behavior", described_class
  end
end
