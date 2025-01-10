require "spec_helper"
require "lutaml/model"

module MultipleMapping
  class Product < Lutaml::Model::Serializable
    attribute :name, Lutaml::Model::Type::String
    attribute :localized_name, Lutaml::Model::Type::String
    attribute :description, Lutaml::Model::Type::String
    attribute :status, Lutaml::Model::Type::String
    attribute :content, Lutaml::Model::Type::String

    yaml do
      map ["name", "product_name"], to: :name
      map ["desc", "description"], to: :description
    end

    json do
      map ["name", "product_name"], to: :name
      map ["desc", "description"], to: :description
    end

    toml do
      map ["name", "product_name"], to: :name
      map ["desc", "description"], to: :description
    end

    xml do
      root "product"
      map_element ["name", "product-name"], to: :name
      map_element ["localized-name", "localized_name"], to: :localized_name
      map_element ["desc", "description"], to: :description
      map_attribute ["status", "product-status"], to: :status
      map_content to: :content
    end
  end

  class CustomModel < Lutaml::Model::Serializable
    attribute :id, Lutaml::Model::Type::String
    attribute :full_name, Lutaml::Model::Type::String
    attribute :size, Lutaml::Model::Type::Integer
    attribute :color, Lutaml::Model::Type::String
    attribute :description, Lutaml::Model::Type::String

    json do
      map ["name", "custom_name"], with: { to: :name_to_json, from: :name_from_json }
      map ["color", "shade"], with: { to: :color_to_json, from: :color_from_json }
      map ["size", "dimension"], with: { to: :size_to_json, from: :size_from_json }
      map ["desc", "description"], with: { to: :desc_to_json, from: :desc_from_json }
    end

    xml do
      root "CustomModel"
      map_attribute ["id", "identifier"], with: { to: :id_to_xml, from: :id_from_xml }
      map_element ["name", "custom-name"], with: { to: :name_to_xml, from: :name_from_xml }
      map_element ["color", "shade"], with: { to: :color_to_xml, from: :color_from_xml }
      map_element ["size", "dimension"], with: { to: :size_to_xml, from: :size_from_xml }
      map_element ["desc", "description"], with: { to: :desc_to_xml, from: :desc_from_xml }
    end

    # Custom methods for JSON
    def name_to_json(model, doc)
      doc["name"] = "JSON Model: #{model.full_name}"
    end

    def name_from_json(model, value)
      model.full_name = value&.sub(/^JSON Model: /, "")
    end

    def color_to_json(model, doc)
      doc["color"] = model.color.upcase
    end

    def color_from_json(model, value)
      model.color = value&.downcase
    end

    def size_to_json(model, doc)
      doc["size"] = model.size + 10
    end

    def size_from_json(model, value)
      model.size = value - 10
    end

    def desc_to_json(model, doc)
      doc["desc"] = "JSON Description: #{model.description}"
    end

    def desc_from_json(model, value)
      model.description = value&.sub(/^JSON Description: /, "")
    end

    # Custom methods for XML
    def id_to_xml(model, parent, doc)
      doc.add_attribute(parent, "id", "XML-#{model.id}")
    end

    def id_from_xml(model, value)
      model.id = value&.sub(/^XML-/, "")
    end

    def name_to_xml(model, parent, doc)
      el = doc.create_element("name")
      doc.add_text(el, "XML Model: #{model.full_name}")
      doc.add_element(parent, el)
    end

    def name_from_xml(model, value)
      model.full_name = value.sub(/^XML Model: /, "")
    end

    def color_to_xml(model, parent, doc)
      el = doc.create_element("color")
      doc.add_text(el, model.color.upcase)
      doc.add_element(parent, el)
    end

    def color_from_xml(model, value)
      model.color = value.downcase
    end

    def size_to_xml(model, parent, doc)
      el = doc.create_element("size")
      doc.add_text(el, (model.size + 10).to_s)
      doc.add_element(parent, el)
    end

    def size_from_xml(model, value)
      model.size = (value.to_i || 0) - 10
    end

    def desc_to_xml(model, parent, doc)
      el = doc.create_element("desc")
      doc.add_text(el, "XML Description: #{model.description}")
      doc.add_element(parent, el)
    end

    def desc_from_xml(model, value)
      model.description = value.sub(/^XML Description: /, "")
    end
  end
end

RSpec.describe MultipleMapping do
  context "with key-value formats" do
    context "with YAML format" do
      let(:yaml_with_name) { "product_name: Coffee Maker\ndescription: Premium coffee maker" }
      let(:yaml_with_desc) { "---\nname: Coffee Maker\ndesc: Premium coffee maker\n" }

      it "handles bidirectional conversion" do
        product1 = MultipleMapping::Product.from_yaml(yaml_with_name)
        product2 = MultipleMapping::Product.from_yaml(yaml_with_desc)

        # keys for name and description are :name and :desc respectively since
        # they are first element in their respective mapping array

        expected_yaml = "---\nname: Coffee Maker\ndesc: Premium coffee maker\n"
        expect(product1.to_yaml).to eq(expected_yaml)
        expect(product2.to_yaml).to eq(yaml_with_desc)
      end
    end

    context "with JSON format" do
      let(:json_with_name) { '{"product_name":"Coffee Maker","description":"Premium coffee maker"}' }
      let(:json_with_desc) { '{"name":"Coffee Maker","desc":"Premium coffee maker"}' }

      it "handles bidirectional conversion" do
        product1 = MultipleMapping::Product.from_json(json_with_name)
        product2 = MultipleMapping::Product.from_json(json_with_desc)

        # keys for name and description are :name and :desc respectively since
        # they are first element in their respective mapping array
        expected_json = '{"name":"Coffee Maker","desc":"Premium coffee maker"}'

        expect(product1.to_json).to eq(expected_json)
        expect(product2.to_json).to eq(json_with_desc)
      end
    end
  end

  context "with XML format" do
    shared_examples "xml adapter with multiple mappings" do |adapter_class|
      before do
        Lutaml::Model::Config.xml_adapter = adapter_class
      end

      around do |example|
        old_adapter = Lutaml::Model::Config.xml_adapter
        Lutaml::Model::Config.xml_adapter = adapter_class

        example.run
      ensure
        Lutaml::Model::Config.xml_adapter = old_adapter
      end

      let(:xml_with_attributes) do
        <<~XML
          <product status="active">
            Some content here
            <name>Coffee Maker</name>
            <description>Premium coffee maker</description>
          </product>
        XML
      end

      let(:xml_with_alternate_attributes) do
        <<~XML
          <product product-status="in-stock">
            Different content
            <product-name>Coffee Maker</product-name>
            <desc>Premium coffee maker</desc>
          </product>
        XML
      end

      it "handles bidirectional conversion with attributes and content" do
        product1 = MultipleMapping::Product.from_xml(xml_with_attributes)
        product2 = MultipleMapping::Product.from_xml(xml_with_alternate_attributes)

        # Key for element name is :name since it is first element in mapping array and same for status attribute
        expected_xml_product1 = <<~XML
          <product status="active">
            <name>Coffee Maker</name>
            <desc>Premium coffee maker</desc>
            Some content here
          </product>
        XML

        expected_xml_product2 = <<~XML
          <product status="in-stock">
            <name>Coffee Maker</name>
            <desc>Premium coffee maker</desc>
            Different content
          </product>
        XML

        expect(product1.name).to eq("Coffee Maker")
        expect(product1.status).to eq("active")
        expect(product2.status).to eq("in-stock")

        expect(product1.to_xml).to be_equivalent_to(expected_xml_product1)
        expect(product2.to_xml).to be_equivalent_to(expected_xml_product2)
      end
    end

    context "with Nokogiri adapter" do
      it_behaves_like "xml adapter with multiple mappings", Lutaml::Model::XmlAdapter::NokogiriAdapter
    end

    context "with Ox adapter" do
      it_behaves_like "xml adapter with multiple mappings", Lutaml::Model::XmlAdapter::OxAdapter
    end
  end

  context "with CustomModel" do
    context "with JSON format" do
      let(:json_with_alternate) { '{"custom_name":"JSON Model: Vase","shade":"BLUE","dimension":22,"description":"JSON Description: A beautiful ceramic vase"}' }
      let(:json_with_standard) { '{"name":"JSON Model: Vase","color":"BLUE","size":22,"desc":"JSON Description: A beautiful ceramic vase"}' }

      it "handles bidirectional conversion with custom methods" do
        model1 = MultipleMapping::CustomModel.from_json(json_with_alternate)
        model2 = MultipleMapping::CustomModel.from_json(json_with_standard)

        # keys are 'name', 'color', 'size', 'desc' respectively since
        # they are first element in their respective mapping array
        expected_json = '{"name":"JSON Model: Vase","color":"BLUE","size":22,"desc":"JSON Description: A beautiful ceramic vase"}'

        expect(model1.to_json).to eq(expected_json)
        expect(model2.to_json).to eq(expected_json)
      end
    end

    context "with XML format" do
      shared_examples "xml adapter with custom methods" do |_adapter_class|
        before do
          Lutaml::Model::Config.xml_adapter = Lutaml::Model::XmlAdapter::NokogiriAdapter
        end

        let(:xml_with_alternate) do
          <<~XML
            <CustomModel identifier="123">
              <custom-name>XML Model: Vase</custom-name>
              <shade>BLUE</shade>
              <dimension>22</dimension>
              <description>XML Description: A beautiful ceramic vase</description>
            </CustomModel>
          XML
        end

        let(:xml_with_standard) do
          <<~XML
            <CustomModel identifier="123">
              <name>XML Model: Vase</name>
              <color>BLUE</color>
              <size>22</size>
              <desc>XML Description: A beautiful ceramic vase</desc>
            </CustomModel>
          XML
        end

        it "handles bidirectional conversion with custom methods" do
          model1 = MultipleMapping::CustomModel.from_xml(xml_with_alternate)
          model2 = MultipleMapping::CustomModel.from_xml(xml_with_standard)

          # Element names are 'name', 'color', 'size', 'desc' respectively since
          # they are first element in their respective mapping array
          expected_xml = <<~XML
            <CustomModel id="XML-123">
              <name>XML Model: Vase</name>
              <color>BLUE</color>
              <size>22</size>
              <desc>XML Description: A beautiful ceramic vase</desc>
            </CustomModel>
          XML
          expect(model1.to_xml).to be_equivalent_to(expected_xml)
          expect(model2.to_xml).to be_equivalent_to(expected_xml)
        end
      end

      context "with Nokogiri adapter" do
        it_behaves_like "xml adapter with custom methods", Lutaml::Model::XmlAdapter::NokogiriAdapter
      end

      context "with Ox adapter" do
        it_behaves_like "xml adapter with custom methods", Lutaml::Model::XmlAdapter::OxAdapter
      end
    end
  end
end
