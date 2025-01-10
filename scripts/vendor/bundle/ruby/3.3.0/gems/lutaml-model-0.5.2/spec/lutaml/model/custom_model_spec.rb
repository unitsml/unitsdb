require "spec_helper"

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
    map_element :street, to: :street
    map_element :city, to: :city
  end
end

class CustomModelParentMapper < Lutaml::Model::Serializable
  model CustomModelParent

  attribute :first_name, Lutaml::Model::Type::String
  attribute :middle_name, Lutaml::Model::Type::String
  attribute :last_name, Lutaml::Model::Type::String
  attribute :child_mapper, CustomModelChildMapper

  xml do
    map_element :first_name, to: :first_name
    map_element :middle_name, to: :middle_name
    map_element :last_name, to: :last_name
    map_element :CustomModelChild,
                with: { to: :child_to_xml, from: :child_from_xml }
  end

  def child_to_xml(model, parent, doc)
    child_el = doc.create_element("CustomModelChild")
    street_el = doc.create_element("street")
    city_el = doc.create_element("city")

    doc.add_text(street_el, model.child_mapper.street)
    doc.add_text(city_el, model.child_mapper.city)

    doc.add_element(child_el, street_el)
    doc.add_element(child_el, city_el)
    doc.add_element(parent, child_el)
  end

  def child_from_xml(model, value)
    model.child_mapper ||= CustomModelChild.new

    model.child_mapper.street = value["street"].text
    model.child_mapper.city = value["city"].text
  end
end

module CustomModelSpecs
  class TextElement < Lutaml::Model::Serializable
    attribute :sup, :string
    attribute :sub, :string
    attribute :text, :string

    xml do
      root "text-element"

      map_content to: :text

      map_element "sup", to: :sup
      map_element "sub", to: :sub
    end
  end

  class Id
    attr_accessor :id, :prefix
  end

  class Docid < Lutaml::Model::Serializable
    model Id
    attribute :id, TextElement

    xml do
      root "docid", mixed: true

      map_content to: :text, delegate: :id
      map_element :sub, to: :sub, delegate: :id
      map_element :sup, to: :sup, delegate: :id
    end
  end

  class BibliographicItem
    attr_accessor :type, :title, :schema_version, :language

    def initialize(**attr)
      @type = attr["type"]
      @title = attr["title"]
      @schema_version = attr["schema_version"]
      @language = attr["language"]
    end
  end

  class Bibdata < Lutaml::Model::Serializable
    model BibliographicItem
  end

  class MixedWithNestedContent < Lutaml::Model::Serializable
    attribute :street, :string, raw: true
    attribute :city, :string, raw: true
    attribute :bibdata, Bibdata

    xml do
      root "MixedWithNestedContent", mixed: true

      map_element "street", to: :street
      map_element "city", to: :city
      map_element "bibdata",
                  to: :bibdata,
                  with: { from: :bibdata_from_xml, to: :bibdata_to_xml }
    end

    def bibdata_from_xml(model, value)
      model.bibdata = BibliographicItem.new(
        "type" => value["type"],
        "title" => value["title"],
        "language" => value["title"]["language"],
        "schema_version" => value["schema-version"],
      )
    end

    def bibdata_to_xml(model, _parent, doc)
      attributes = {
        "type" => model.bibdata.type,
        "schema-version" => model.bibdata.schema_version,
      }
      lang = model.bibdata.language

      doc.create_and_add_element("bibdata", attributes: attributes) do
        doc.create_and_add_element("title", attributes: { language: lang }) do
          doc.add_text(doc, model.bibdata.title.text)
        end
      end
    end
  end

  class CustomId < Lutaml::Model::Serializable
    model Id
    attribute :id, :string
    attribute :prefix, :string

    xml do
      root "custom-id"
      map_attribute "prefix", to: :prefix
      map_content with: { to: :id_to_xml, from: :id_from_xml }
    end

    def id_to_xml(model, _parent, doc)
      content = "ABC-#{model.id}"
      doc.add_text(doc, content)
    end

    def id_from_xml(model, value)
      id = value.split("-").last
      model.id = id.to_i
    end
  end
end

RSpec.describe "CustomModel" do
  let(:parent_mapper) { CustomModelParentMapper }
  let(:child_mapper) { CustomModelChildMapper }
  let(:parent_model) { CustomModelParent }
  let(:child_model) { CustomModelChild }

  context "with JSON mapping" do
    let(:input_json) do
      {
        first_name: "John",
        last_name: "Doe",
        child_mapper: {
          street: "Oxford Street",
          city: "London",
        },
      }.to_json
    end

    describe ".from_json" do
      it "maps JSON string to custom model" do
        instance = parent_mapper.from_json(input_json)

        expect(instance.class).to eq(parent_model)
        expect(instance.first_name).to eq("John")
        expect(instance.last_name).to eq("Doe")
        expect(instance.name).to eq("John Doe")

        expect(instance.child_mapper.class).to eq(child_model)
        expect(instance.child_mapper.street).to eq("Oxford Street")
        expect(instance.child_mapper.city).to eq("London")
      end
    end

    describe ".to_json" do
      it "with wrong model raises an exception" do
        msg = /argument is a 'String' but should be a '#{parent_model.name}/

        expect do
          parent_mapper.to_json("")
        end.to raise_error(Lutaml::Model::IncorrectModelError, msg)
      end

      it "with correct model converts objects to json" do
        instance = parent_mapper.from_json(input_json)

        expect(parent_mapper.to_json(instance)).to eq(input_json)
      end
    end
  end

  context "with YAML mapping" do
    let(:input_yaml) do
      {
        "first_name" => "John",
        "last_name" => "Doe",
        "child_mapper" => {
          "street" => "Oxford Street",
          "city" => "London",
        },
      }.to_yaml
    end

    describe ".from_yaml" do
      it "maps YAML to custom model" do
        instance = parent_mapper.from_yaml(input_yaml)

        expect(instance.class).to eq(parent_model)
        expect(instance.first_name).to eq("John")
        expect(instance.last_name).to eq("Doe")
        expect(instance.name).to eq("John Doe")

        expect(instance.child_mapper.class).to eq(child_model)
        expect(instance.child_mapper.street).to eq("Oxford Street")
        expect(instance.child_mapper.city).to eq("London")
      end
    end

    describe ".to_yaml" do
      it "with wrong model raises an exception" do
        msg = /argument is a 'String' but should be a '#{parent_model.name}/

        expect do
          parent_mapper.to_yaml("")
        end.to raise_error(Lutaml::Model::IncorrectModelError, msg)
      end

      it "with correct model converts objects to yaml" do
        instance = parent_mapper.from_yaml(input_yaml)

        expect(parent_mapper.to_yaml(instance)).to eq(input_yaml)
      end
    end
  end

  context "with TOML mapping" do
    let(:input_toml) do
      <<~TOML
        first_name = "John"
        last_name = "Doe"
        [child_mapper]
        city = "London"
        street = "Oxford Street"
      TOML
    end

    describe ".from_toml" do
      it "maps TOML content to custom model" do
        instance = parent_mapper.from_toml(input_toml)

        expect(instance.class).to eq(parent_model)
        expect(instance.first_name).to eq("John")
        expect(instance.last_name).to eq("Doe")
        expect(instance.name).to eq("John Doe")

        expect(instance.child_mapper.class).to eq(child_model)
        expect(instance.child_mapper.street).to eq("Oxford Street")
        expect(instance.child_mapper.city).to eq("London")
      end
    end

    describe ".to_toml" do
      it "with wrong model raises an exception" do
        msg = /argument is a 'String' but should be a '#{parent_model.name}/

        expect do
          parent_mapper.to_toml("")
        end.to raise_error(Lutaml::Model::IncorrectModelError, msg)
      end

      it "with correct model converts objects to toml" do
        instance = parent_mapper.from_toml(input_toml)

        expect(parent_mapper.to_toml(instance)).to eq(input_toml)
      end
    end
  end

  context "with XML mapping" do
    let(:input_xml) do
      <<~XML
        <CustomModelParent>
          <first_name>John</first_name>
          <last_name>Doe</last_name>
          <CustomModelChild>
            <street>Oxford Street</street>
            <city>London</city>
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
      it "with wrong model raises an exception" do
        msg = /argument is a 'String' but should be a '#{parent_model.name}/

        expect do
          parent_mapper.to_xml("")
        end.to raise_error(Lutaml::Model::IncorrectModelError, msg)
      end

      it "with correct model converts objects to xml using custom methods" do
        instance = parent_mapper.from_xml(input_xml)
        result_xml = parent_mapper.to_xml(instance)

        expect(result_xml.gsub(/\s+/, "")).to eq(input_xml.gsub(/\s+/, ""))
      end
    end

    describe "custom serialization methods" do
      it "uses custom to_xml method for child_mapper" do
        instance = parent_model.new
        instance.first_name = "John"
        instance.last_name = "Doe"
        instance.child_mapper = child_model.new
        instance.child_mapper.street = "Custom Street"
        instance.child_mapper.city = "Custom City"

        result_xml = parent_mapper.to_xml(instance)
        expect(result_xml).to include("<CustomModelChild>")
        expect(result_xml).to include("<street>Custom Street</street>")
        expect(result_xml).to include("<city>Custom City</city>")
      end

      it "uses custom from_xml method for child_mapper" do
        custom_xml = <<~XML
          <CustomModelParent>
            <first_name>Jane</first_name>
            <last_name>Smith</last_name>
            <CustomModelChild>
              <street>Custom Avenue</street>
              <city>New City</city>
            </CustomModelChild>
          </CustomModelParent>
        XML

        instance = parent_mapper.from_xml(custom_xml)
        expect(instance.child_mapper.street).to eq("Custom Avenue")
        expect(instance.child_mapper.city).to eq("New City")
      end

      it "uses delegate to for child mapper class" do
        xml = "<docid>Str<sub>2</sub>text<sup>1</sup>123</docid>"

        docid = CustomModelSpecs::Docid.from_xml(xml)

        expect(CustomModelSpecs::Docid.to_xml(docid)).to eq(xml)
      end
    end

    describe "custom methods with custom model" do
      it "uses delegate to for child mapper class" do
        xml = <<~XML
          <MixedWithNestedContent>
            <street>
              A <p>b</p> B <p>c</p> C
            </street>
            <bibdata type="collection" schema-version="v1.2.8">
              <title language="en">
                JCGM Collection 1
              </title>
            </bibdata>
          </MixedWithNestedContent>
        XML

        expected_xml = <<~XML
          <MixedWithNestedContent>
            <street>
              A &lt;p&gt;b&lt;/p&gt; B &lt;p&gt;c&lt;/p&gt; C
            </street>
            <bibdata type="collection" schema-version="v1.2.8">
              <title language="en">
                JCGM Collection 1
              </title>
            </bibdata>
          </MixedWithNestedContent>
        XML

        bibdata = CustomModelSpecs::MixedWithNestedContent.from_xml(xml)

        expect(bibdata.to_xml).to be_equivalent_to(expected_xml)
      end
    end
  end

  context "with custom methods" do
    describe ".xml serialization" do
      it "handles custom content mapping methods" do
        xml = '<custom-id prefix="ABC">ABC-123</custom-id>'

        instance = CustomModelSpecs::Id.new
        instance.id = 123
        instance.prefix = "ABC"
        result_xml = CustomModelSpecs::CustomId.to_xml(instance)
        expect(result_xml).to eq(xml)
      end
    end

    describe ".xml deserialization" do
      it "handles custom content mapping methods" do
        xml = '<custom-id prefix="ABC">ABC-123</custom-id>'
        instance = CustomModelSpecs::CustomId.from_xml(xml)

        expect(instance.id).to eq(123)
        expect(instance.prefix).to eq("ABC")
      end
    end
  end
end
