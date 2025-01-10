require "spec_helper"
require "lutaml/model"
require "lutaml/model/xml_adapter/nokogiri_adapter"
require "lutaml/model/xml_adapter/ox_adapter"

module CDATA
  class Beta < Lutaml::Model::Serializable
    attribute :element1, :string

    xml do
      root "beta"
      map_content to: :element1, cdata: true
    end
  end

  class Alpha < Lutaml::Model::Serializable
    attribute :element1, :string
    attribute :element2, :string
    attribute :element3, :string
    attribute :beta, Beta

    xml do
      root "alpha"

      map_element "element1", to: :element1, cdata: false
      map_element "element2", to: :element2, cdata: true
      map_element "element3", to: :element3, cdata: false
      map_element "beta", to: :beta
    end
  end

  class Address < Lutaml::Model::Serializable
    attribute :street, :string
    attribute :city, :string
    attribute :house, :string
    attribute :address, Address

    xml do
      root "address"
      map_element "street", to: :street
      map_element "city", with: { from: :city_from_xml, to: :city_to_xml }, cdata: true
      map_element "house", with: { from: :house_from_xml, to: :house_to_xml }, cdata: false
      map_element "address", to: :address
    end

    def house_from_xml(model, node)
      model.house = node
    end

    def house_to_xml(model, _parent, doc)
      doc.create_and_add_element("house") do |element|
        element.add_text(element, model.house, cdata: false)
      end
    end

    def city_from_xml(model, node)
      model.city = node
    end

    def city_to_xml(model, _parent, doc)
      doc.create_and_add_element("city") do |element|
        element.add_text(element, model.city, cdata: true)
      end
    end
  end

  class CustomModelChild
    attr_accessor :street, :city
  end

  class CustomModelParent
    attr_accessor :first_name, :middle_name, :last_name, :child_mapper

    def name
      "#{first_name} #{last_name}"
    end
  end

  class CustomModelChildMapper < Lutaml::Model::Serializable
    model CustomModelChild

    attribute :street, Lutaml::Model::Type::String
    attribute :city, Lutaml::Model::Type::String

    xml do
      map_element :street, to: :street, cdata: true
      map_element :city, to: :city, cdata: true
    end
  end

  class CustomModelParentMapper < Lutaml::Model::Serializable
    model CustomModelParent

    attribute :first_name, Lutaml::Model::Type::String
    attribute :middle_name, Lutaml::Model::Type::String
    attribute :last_name, Lutaml::Model::Type::String
    attribute :child_mapper, CustomModelChildMapper

    xml do
      root "CustomModelParent"
      map_element :first_name, to: :first_name, cdata: true
      map_element :middle_name, to: :middle_name, cdata: true
      map_element :last_name, to: :last_name, cdata: false
      map_element :CustomModelChild, with: { to: :child_to_xml, from: :child_from_xml }, cdata: true
    end

    def child_to_xml(model, _parent, doc)
      doc.create_and_add_element("CustomModelChild") do |child_el|
        child_el.create_and_add_element("street") do |street_el|
          street_el.add_text(street_el, model.child_mapper.street, cdata: true)
        end
        child_el.create_and_add_element("city") do |city_el|
          city_el.add_text(city_el, model.child_mapper.city, cdata: true)
        end
      end
    end

    def child_from_xml(model, value)
      model.child_mapper ||= CustomModelChild.new

      model.child_mapper.street = value["street"].text
      model.child_mapper.city = value["city"].text
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
      map_element :bold, to: :bold, cdata: true
      map_element :italic, to: :italic, cdata: true
      map_element :underline, to: :underline, cdata: true
      map_content to: :content, cdata: true
    end
  end

  class RootMixedContentNested < Lutaml::Model::Serializable
    attribute :id, :string
    attribute :data, :string
    attribute :content, RootMixedContent
    attribute :sup, :string, collection: true
    attribute :sub, :string, collection: true

    xml do
      root "RootMixedContentNested", mixed: true
      map_content to: :data, cdata: true
      map_attribute :id, to: :id
      map_element :sup, to: :sup, cdata: true
      map_element :sub, to: :sub, cdata: false
      map_element "MixedContent", to: :content
    end
  end

  class DefaultValue < Lutaml::Model::Serializable
    attribute :name, :string, default: -> { "Default Value" }
    attribute :temperature, :integer, default: -> { 1050 }
    attribute :opacity, :string, default: -> { "Opaque" }
    attribute :content, :string, default: -> { " " }

    xml do
      root "DefaultValue"
      map_element "name", to: :name, render_default: true, cdata: true
      map_element "temperature", to: :temperature, render_default: true, cdata: true
      map_element "opacity", to: :opacity, cdata: false, render_default: true
      map_content to: :content, cdata: true, render_default: true
    end
  end
end

RSpec.describe "CDATA" do
  let(:parent_mapper) { CDATA::CustomModelParentMapper }
  let(:child_mapper) { CDATA::CustomModelChildMapper }
  let(:parent_model) { CDATA::CustomModelParent }
  let(:child_model) { CDATA::CustomModelChild }

  shared_examples "cdata behavior" do |adapter_class|
    around do |example|
      old_adapter = Lutaml::Model::Config.xml_adapter
      Lutaml::Model::Config.xml_adapter = adapter_class
      example.run
    ensure
      Lutaml::Model::Config.xml_adapter = old_adapter
    end

    context "with CDATA option" do
      let(:xml) do
        <<~XML.strip
          <alpha>
            <element1><![CDATA[foo]]></element1>
            <element2><![CDATA[one]]></element2>
            <element2><![CDATA[two]]></element2>
            <element2><![CDATA[three]]></element2>
            <element3>bar</element3>
            <beta><![CDATA[child]]></beta>
          </alpha>
        XML
      end

      let(:expected_xml) do
        <<~XML.strip
          <alpha>
            <element1>foo</element1>
            <element2>
              <![CDATA[one]]>
            </element2>
            <element2>
              <![CDATA[two]]>
            </element2>
            <element2>
              <![CDATA[three]]>
            </element2>
            <element3>bar</element3>
            <beta>
              <![CDATA[child]]>
            </beta>
          </alpha>
        XML
      end

      it "maps xml to object" do
        instance = CDATA::Alpha.from_xml(xml)

        expect(instance.element1).to eq("foo")
        expect(instance.element2).to eq(%w[one two three])
        expect(instance.element3).to eq("bar")
        expect(instance.beta.element1).to eq("child")
      end

      it "converts objects to xml" do
        instance = CDATA::Alpha.new(
          element1: "foo",
          element2: %w[one two three],
          element3: "bar",
          beta: CDATA::Beta.new(element1: "child"),
        )

        expect(instance.to_xml).to be_equivalent_to(expected_xml)
      end
    end

    context "with custom methods" do
      let(:xml) do
        <<~XML
          <address>
            <street>A</street>
            <city><![CDATA[B]]></city>
            <house><![CDATA[H]]></house>
            <address>
              <street>C</street>
              <city><![CDATA[D]]></city>
              <house><![CDATA[G]]></house>
            </address>
          </address>
        XML
      end

      let(:expected_xml) do
        <<~XML
          <address>
            <street>A</street>
            <city>
              <![CDATA[B]]>
            </city>
            <house>H</house>
            <address>
              <street>C</street>
              <city>
                <![CDATA[D]]>
              </city>
              <house>G</house>
            </address>
          </address>
        XML
      end

      it "round-trips XML" do
        model = CDATA::Address.from_xml(xml)
        expect(model.to_xml).to be_equivalent_to(expected_xml)
      end
    end

    context "with custom models" do
      let(:input_xml) do
        <<~XML
          <CustomModelParent>
            <first_name><![CDATA[John]]></first_name>
            <last_name><![CDATA[Doe]]></last_name>
            <CustomModelChild>
              <street><![CDATA[Oxford Street]]></street>
              <city><![CDATA[London]]></city>
            </CustomModelChild>
          </CustomModelParent>
        XML
      end

      let(:expected_nokogiri_xml) do
        <<~XML
          <CustomModelParent>
            <first_name><![CDATA[John]]></first_name>
            <last_name>Doe</last_name>
            <CustomModelChild>
              <street><![CDATA[Oxford Street]]></street>
              <city><![CDATA[London]]></city>
            </CustomModelChild>
          </CustomModelParent>
        XML
      end

      let(:expected_ox_xml) do
        <<~XML
          <CustomModelParent>
            <first_name>
              <![CDATA[John]]>
            </first_name>
            <last_name>Doe</last_name>
            <CustomModelChild>
              <street>
                <![CDATA[Oxford Street]]>
              </street>
              <city>
                <![CDATA[London]]>
              </city>
            </CustomModelChild>
          </CustomModelParent>
        XML
      end

      describe ".from_xml" do
        it "maps XML content to custom model using custom methods" do
          instance = parent_mapper.from_xml(input_xml)

          expect(instance.class).to eq(parent_model)
          expect(instance.first_name).to eq("John")
          expect(instance.last_name).to eq("Doe")
          expect(instance.name).to eq("John Doe")

          expect(instance.child_mapper.class).to eq(child_model)
          expect(instance.child_mapper.street).to eq("Oxford Street")
          expect(instance.child_mapper.city).to eq("London")
        end
      end

      describe ".to_xml" do
        it "with correct model converts objects to xml using custom methods" do
          instance = parent_mapper.from_xml(input_xml)
          result_xml = parent_mapper.to_xml(instance)

          expected_output = adapter_class == Lutaml::Model::XmlAdapter::OxAdapter ? expected_ox_xml : expected_nokogiri_xml

          expect(result_xml.strip).to eq(expected_output.strip)
        end
      end
    end

    context "when mixed: true is set for nested content" do
      let(:xml) do
        <<~XML
          <RootMixedContentNested id="outer123">
            <![CDATA[The following text is about the Moon.]]>
              <MixedContent id="inner456">
                <![CDATA[The Earth's Moon rings like a ]]>
                <bold><![CDATA[bell]]></bold>
                <![CDATA[ when struck by meteroids. Distanced from the Earth by ]]>
                <italic><![CDATA[384,400 km]]></italic>,
                <![CDATA[ ,its surface is covered in ]]>
                <underline><![CDATA[craters]]></underline>.
                <![CDATA[ .Ain't that ]]>
                <bold><![CDATA[cool]]></bold>
                <![CDATA[ ? ]]>
              </MixedContent>
            <sup><![CDATA[1]]></sup>: <![CDATA[The Moon is not a planet.]]>
            <sup><![CDATA[2]]></sup>: <![CDATA[The Moon's atmosphere is mainly composed of helium in the form of He]]><sub><![CDATA[2]]></sub>.
          </RootMixedContentNested>
        XML
      end

      expected_xml = "<RootMixedContentNested id=\"outer123\"><![CDATA[The following text is about the Moon.]]><MixedContent id=\"inner456\"><![CDATA[The Earth's Moon rings like a ]]><bold><![CDATA[bell]]></bold><![CDATA[ when struck by meteroids. Distanced from the Earth by ]]><italic><![CDATA[384,400 km]]></italic><![CDATA[ ,its surface is covered in ]]><underline><![CDATA[craters]]></underline><![CDATA[ .Ain't that ]]><bold><![CDATA[cool]]></bold><![CDATA[ ? ]]></MixedContent><sup><![CDATA[1]]></sup><![CDATA[The Moon is not a planet.]]><sup><![CDATA[2]]></sup><![CDATA[The Moon's atmosphere is mainly composed of helium in the form of He]]><sub>2</sub></RootMixedContentNested>"

      expected_ox_xml = <<~XML
        <RootMixedContentNested id="outer123">
          <![CDATA[The following text is about the Moon.]]>
          <MixedContent id="inner456">
            <![CDATA[The Earth's Moon rings like a ]]>
            <bold>
              <![CDATA[bell]]>
            </bold>
            <![CDATA[ when struck by meteroids. Distanced from the Earth by ]]>
            <italic>
              <![CDATA[384,400 km]]>
            </italic>
            <![CDATA[ ,its surface is covered in ]]>
            <underline>
              <![CDATA[craters]]>
            </underline>
            <![CDATA[ .Ain't that ]]>
            <bold>
              <![CDATA[cool]]>
            </bold>
            <![CDATA[ ? ]]>
          </MixedContent>
          <sup>
            <![CDATA[1]]>
          </sup>
          <![CDATA[The Moon is not a planet.]]>
          <sup>
            <![CDATA[2]]>
          </sup>
          <![CDATA[The Moon's atmosphere is mainly composed of helium in the form of He]]>
          <sub>2</sub>
        </RootMixedContentNested>
      XML

      it "deserializes and serializes mixed content correctly" do
        parsed = CDATA::RootMixedContentNested.from_xml(xml)

        expected_content = [
          "The Earth's Moon rings like a ",
          " when struck by meteroids. Distanced from the Earth by ",
          " ,its surface is covered in ",
          " .Ain't that ",
          " ? ",
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
            expected_xml = expected_ox_xml
          end

          expect(content).to eq(expected_output)
        end

        serialized = parsed.to_xml
        expect(serialized).to eq(expected_xml)
      end
    end

    context "when defualt: true is set for attributes default values" do
      let(:xml) do
        <<~XML
          <DefaultValue>
            <![CDATA[The following text is about the Moon]]>
            <temperature>
              <![CDATA[500]]>
            </temperature>
            <![CDATA[The Moon's atmosphere is mainly composed of helium in the form]]>
          </DefaultValue>
        XML
      end

      expected_xml = "<DefaultValue><name><![CDATA[Default Value]]></name><temperature><![CDATA[500]]></temperature><opacity>Opaque</opacity><![CDATA[The following text is about the MoonThe Moon's atmosphere is mainly composed of helium in the form]]></DefaultValue>"

      expected_ox_xml = <<~XML
        <DefaultValue>
          <name>
            <![CDATA[Default Value]]>
          </name>
          <temperature>
            <![CDATA[500]]>
          </temperature>
          <opacity>Opaque</opacity>
          <![CDATA[The following text is about the MoonThe Moon's atmosphere is mainly composed of helium in the form]]>
        </DefaultValue>
      XML

      it "deserializes and serializes mixed content correctly" do
        parsed = CDATA::DefaultValue.from_xml(xml)

        expected_content = [
          "The following text is about the Moon",
          "The Moon's atmosphere is mainly composed of helium in the form",
        ]

        expect(parsed.name).to eq("Default Value")
        expect(parsed.opacity).to eq("Opaque")
        expect(parsed.temperature).to eq(500)

        parsed.content.each_with_index do |content, index|
          expected_output = expected_content[index]

          # due to the difference in capturing
          # newlines in ox and nokogiri adapters
          if adapter_class == Lutaml::Model::XmlAdapter::OxAdapter
            expected_xml = expected_ox_xml
          end

          expect(content).to eq(expected_output)
        end

        serialized = parsed.to_xml
        expect(serialized).to eq(expected_xml)
      end
    end
  end

  describe Lutaml::Model::XmlAdapter::NokogiriAdapter do
    it_behaves_like "cdata behavior", described_class
  end

  describe Lutaml::Model::XmlAdapter::OxAdapter do
    it_behaves_like "cdata behavior", described_class
  end
end
