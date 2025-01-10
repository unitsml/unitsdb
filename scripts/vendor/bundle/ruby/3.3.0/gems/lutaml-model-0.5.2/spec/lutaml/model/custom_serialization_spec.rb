require "spec_helper"
require "lutaml/model"

class CustomSerialization < Lutaml::Model::Serializable
  attribute :full_name, :string
  attribute :size, :integer
  attribute :color, :string
  attribute :description, :string

  json do
    map "name", with: { to: :name_to_json, from: :name_from_json }
    map "color", with: { to: :color_to_json, from: :color_from_json }
    map "size", with: { to: :size_to_json, from: :size_from_json }
    map "description",
        with: { to: :description_to_json, from: :description_from_json }
  end

  xml do
    root "CustomSerialization"

    # name, color are used to test XML elements with custom methods
    map_element "Name", with: { to: :name_to_xml, from: :name_from_xml }
    map_element "Color", with: { to: :color_to_xml, from: :color_from_xml }

    # size is used to test XML attribute with custom methods
    map_attribute "Size", with: { to: :size_to_xml, from: :size_from_xml }

    # description is used to test XML textual content
    map_content with: { to: :description_to_xml, from: :description_from_xml }
  end

  def name_to_json(model, doc)
    doc["name"] = "JSON Masterpiece: #{model.full_name}"
  end

  def name_from_json(model, value)
    model.full_name = value.sub(/^JSON Masterpiece: /, "")
  end

  def size_to_json(model, doc)
    doc["size"] = model.size + 3
  end

  def size_from_json(model, value)
    model.size = value - 3
  end

  def color_to_json(model, doc)
    doc["color"] = model.color.upcase
  end

  def color_from_json(model, value)
    model.color = value.downcase
  end

  def description_to_json(model, doc)
    doc["description"] = "JSON Description: #{model.description}"
  end

  def description_from_json(model, value)
    model.description = value.sub(/^JSON Description: /, "")
  end

  def name_to_xml(model, parent, doc)
    el = doc.create_element("Name")
    doc.add_text(el, "XML Masterpiece: #{model.full_name}")
    doc.add_element(parent, el)
  end

  def name_from_xml(model, value)
    model.full_name = value.sub(/^XML Masterpiece: /, "")
  end

  def size_to_xml(model, parent, doc)
    doc.add_attribute(parent, "Size", model.size + 3)
  end

  def size_from_xml(model, value)
    model.size = value.to_i - 3
  end

  def color_to_xml(model, parent, doc)
    color_element = doc.create_element("Color")
    doc.add_text(color_element, model.color.upcase)
    doc.add_element(parent, color_element)
  end

  def color_from_xml(model, value)
    model.color = value.downcase
  end

  def description_to_xml(model, parent, doc)
    doc.add_text(parent, "XML Description: #{model.description}")
  end

  def description_from_xml(model, value)
    model.description = value.join.strip.sub(/^XML Description: /, "")
  end
end

RSpec.describe CustomSerialization do
  let(:attributes) do
    {
      full_name: "Vase",
      size: 12,
      color: "blue",
      description: "A beautiful ceramic vase",
    }
  end
  let(:model) { described_class.new(attributes) }

  context "with JSON serialization" do
    it "serializes to JSON with custom methods" do
      expected_json = {
        name: "JSON Masterpiece: Vase",
        color: "BLUE",
        size: 15,
        description: "JSON Description: A beautiful ceramic vase",
      }.to_json

      expect(model.to_json).to eq(expected_json)
    end

    it "deserializes from JSON with custom methods" do
      json = {
        name: "JSON Masterpiece: Vase",
        color: "BLUE",
        size: 15,
        description: "JSON Description: A beautiful ceramic vase",
      }.to_json

      ceramic = described_class.from_json(json)

      expect(ceramic.full_name).to eq(model.full_name)
      expect(ceramic.size).to eq(model.size)
      expect(ceramic.color).to eq(model.color)
      expect(ceramic.description).to eq(model.description)
    end
  end

  context "with partial JSON input" do
    it "deserializes from JSON with missing attributes" do
      json = {
        name: "JSON Masterpiece: Vase",
        color: "BLUE",
      }.to_json

      ceramic = described_class.from_json(json)

      expect(ceramic.full_name).to eq("Vase")
      expect(ceramic.color).to eq("blue")
      expect(ceramic.size).to be_nil
      expect(ceramic.description).to be_nil
    end
  end

  context "with XML serialization" do
    it "serializes to XML with custom methods" do
      expected_xml = <<~XML
        <CustomSerialization Size="15">
          <Name>XML Masterpiece: Vase</Name>
          <Color>BLUE</Color>
          XML Description: A beautiful ceramic vase
        </CustomSerialization>
      XML

      expect(model.to_xml).to be_equivalent_to(expected_xml)
    end

    it "deserializes from XML with custom methods" do
      xml = <<~XML
        <CustomSerialization Size="15">
          <Name>XML Masterpiece: Vase</Name>
          <Color>BLUE</Color>
          XML Description: A beautiful ceramic vase
        </CustomSerialization>
      XML

      ceramic = described_class.from_xml(xml)
      expect(ceramic.full_name).to eq(model.full_name)
      expect(ceramic.size).to eq(model.size)
      expect(ceramic.color).to eq(model.color)
      expect(ceramic.description).to eq(model.description)
    end
  end
end
