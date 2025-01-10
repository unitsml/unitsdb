require "spec_helper"
require "lutaml/model"

class RenderNilNested < Lutaml::Model::Serializable
  attribute :name, Lutaml::Model::Type::String

  xml do
    root "render_nil_nested"

    map_element "name", to: :name
  end
end

class RenderNil < Lutaml::Model::Serializable
  attribute :name, Lutaml::Model::Type::String, default: -> {
                                                           "Unnamed Pottery"
                                                         }
  attribute :clay_type, Lutaml::Model::Type::String
  attribute :glaze, Lutaml::Model::Type::String
  attribute :dimensions, Lutaml::Model::Type::String, collection: true
  attribute :render_nil_nested, RenderNilNested

  json do
    map "name", to: :name, render_nil: true
    map "clay_type", to: :clay_type, render_nil: true
    map "glaze", to: :glaze, render_nil: true
    map "dimensions", to: :dimensions, render_nil: false
  end

  xml do
    root "render_nil"
    map_element "name", to: :name, render_nil: true
    map_element "clay_type", to: :clay_type, render_nil: false
    map_element "glaze", to: :glaze, render_nil: true
    map_element "render_nil_nested", to: :render_nil_nested, render_nil: true,
                                     render_default: true
    map_element "dimensions", to: :dimensions, render_nil: false
  end

  yaml do
    map "name", to: :name, render_nil: true
    map "clay_type", to: :clay_type, render_nil: false
    map "glaze", to: :glaze, render_nil: true
    map "dimensions", to: :dimensions, render_nil: false
    map "render_nil_nested", to: :render_nil_nested, render_nil: false
  end

  toml do
    map "name", to: :name, render_nil: true
    map "clay_type", to: :clay_type, render_nil: false
    map "glaze", to: :glaze, render_nil: true
    map "dimensions", to: :dimensions, render_nil: false
  end
end

RSpec.describe RenderNil do
  let(:attributes) do
    {
      name: nil,
      clay_type: nil,
      glaze: nil,
      dimensions: nil,
      render_nil_nested: RenderNilNested.new,
    }
  end

  let(:model) { described_class.new(attributes) }

  it "serializes to JSON with render_nil option" do
    expected_json = {
      name: nil,
      clay_type: nil,
      glaze: nil,
    }.to_json

    expect(model.to_json).to eq(expected_json)
  end

  it "deserializes from JSON with render_nil option" do
    json = attributes.to_json
    pottery = described_class.from_json(json)
    expect(pottery.name).to be_nil
    expect(pottery.clay_type).to be_nil
    expect(pottery.glaze).to be_nil
    expect(pottery.dimensions).to eq([])
  end

  it "serializes to XML with render_nil option" do
    expected_xml = <<~XML
      <render_nil>
        <name/>
        <glaze/>
        <render_nil_nested/>
      </render_nil>
    XML

    expect(model.to_xml).to be_equivalent_to(expected_xml)
  end

  it "deserializes from XML with render_nil option" do
    xml = <<~XML
      <render_nil>
        <name/>
        <glaze/>
      </render_nil>
    XML

    pottery = described_class.from_xml(xml)
    expect(pottery.name).to be_nil
    expect(pottery.glaze).to be_nil
  end

  it "serializes to YAML with render_nil option" do
    expected_yaml = <<~YAML
      ---
      name:
      glaze:
    YAML

    generated_yaml = model.to_yaml.strip

    # Removing empty spaces from the end of the line because of and issue in
    # libyaml -> https://github.com/yaml/libyaml/issues/46
    generated_yaml = generated_yaml.gsub(": \n", ":\n")

    expect(generated_yaml).to eq(expected_yaml.strip)
  end

  it "deserializes from YAML with render_nil option" do
    yaml = <<~YAML
      ---
      glaze:
    YAML

    pottery = described_class.from_yaml(yaml)
    expect(pottery.name).to eq("Unnamed Pottery")
    expect(pottery.glaze).to be_nil
  end
end
