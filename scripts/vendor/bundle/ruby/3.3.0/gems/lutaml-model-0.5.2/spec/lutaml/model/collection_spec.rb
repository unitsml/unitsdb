require "spec_helper"
require "lutaml/model"

module CollectionTests
  class Pot < Lutaml::Model::Serializable
    attribute :material, Lutaml::Model::Type::String

    xml do
      root "pot"
      map_element "material", to: :material
    end
  end

  class Kiln < Lutaml::Model::Serializable
    attribute :brand, Lutaml::Model::Type::String
    attribute :pots, Pot, collection: 0..2
    attribute :temperatures, Lutaml::Model::Type::Integer, collection: true
    attribute :operators, Lutaml::Model::Type::String, collection: (1..),
                                                       default: -> {
                                                         ["Default Operator"]
                                                       }
    attribute :sensors, Lutaml::Model::Type::String, collection: 1..3,
                                                     default: -> {
                                                       ["Default Sensor"]
                                                     }

    xml do
      root "kiln"
      map_attribute "brand", to: :brand
      map_element "pot", to: :pots
      map_element "temperature", to: :temperatures
      map_element "operator", to: :operators
      map_element "sensor", to: :sensors
    end
  end

  class Address < Lutaml::Model::Serializable
    attribute :street, :string
    attribute :city, :string
    attribute :address, Address

    xml do
      root "address"
      map_element "street", to: :street
      map_element "city", with: { from: :city_from_xml, to: :city_to_xml }
      map_element "address", to: :address
    end

    def city_from_xml(model, node)
      model.city = node
    end

    def city_to_xml(model, parent, doc)
      doc.add_element(parent, "<city>#{model.city}</city>")
    end
  end
end

RSpec.describe CollectionTests do
  let(:pots) { [{ material: "clay" }, { material: "ceramic" }] }
  let(:temperatures) { [1200, 1300, 1400] }
  let(:operators) { ["John", "Jane"] }
  let(:sensors) { ["Temp1", "Temp2"] }
  let(:attributes) do
    {
      brand: "Skutt",
      pots: pots,
      temperatures: temperatures,
      operators: operators,
      sensors: sensors,
    }
  end
  let(:model) { CollectionTests::Kiln.new(attributes) }

  let(:model_xml) do
    <<~XML
      <kiln brand="Skutt">
        <pot>
          <material>clay</material>
        </pot>
        <pot>
          <material>ceramic</material>
        </pot>
        <temperature>1200</temperature>
        <temperature>1300</temperature>
        <temperature>1400</temperature>
        <operator>John</operator>
        <operator>Jane</operator>
        <sensor>Temp1</sensor>
        <sensor>Temp2</sensor>
      </kiln>
    XML
  end

  it "initializes with default values" do
    default_model = CollectionTests::Kiln.new
    expect(default_model.brand).to be_nil
    expect(default_model.pots).to eq([])
    expect(default_model.temperatures).to eq([])
    expect(default_model.operators).to eq(["Default Operator"])
    expect(default_model.sensors).to eq(["Default Sensor"])
  end

  it "serializes to XML" do
    expected_xml = model_xml.strip
    expect(model.to_xml.strip).to eq(expected_xml)
  end

  it "deserializes from XML" do
    sample = CollectionTests::Kiln.from_xml(model_xml)
    expect(sample.brand).to eq("Skutt")
    expect(sample.pots.size).to eq(2)
    expect(sample.pots[0].material).to eq("clay")
    expect(sample.pots[1].material).to eq("ceramic")
    expect(sample.temperatures).to eq([1200, 1300, 1400])
    expect(sample.operators).to eq(["John", "Jane"])
    expect(sample.sensors).to eq(["Temp1", "Temp2"])
  end

  it "round-trips XML" do
    xml = model.to_xml
    new_model = CollectionTests::Kiln.from_xml(xml)
    expect(new_model.brand).to eq(model.brand)
    expect(new_model.pots.size).to eq(model.pots.size)
    model.pots.each_with_index do |pot, index|
      expect(new_model.pots[index].material).to eq(pot.material)
    end
    expect(new_model.temperatures).to eq(model.temperatures)
    expect(new_model.operators).to eq(model.operators)
    expect(new_model.sensors).to eq(model.sensors)
  end

  context "when model contains self as attribute" do
    let(:xml) do
      <<~XML
        <address>
          <street>A</street>
          <city>B</city>
          <address>
            <street>C</street>
            <city>D</city>
          </address>
        </address>
      XML
    end

    it "deserializes from XML" do
      model = CollectionTests::Address.from_xml(xml)

      expect(model.street).to eq("A")
      expect(model.city).to eq("B")
      expect(model.address.street).to eq("C")
      expect(model.address.city).to eq("D")
    end

    it "round-trips XML" do
      model = CollectionTests::Address.from_xml(xml)

      expect(model.to_xml).to be_equivalent_to(xml)
    end
  end

  context "when collection counts are below given ranges" do
    let(:invalid_attributes) do
      attributes.merge(operators: [], sensors: [])
    end

    it "raises ValidationError containing CollectionCountOutOfRangeError for operators" do
      kiln = CollectionTests::Kiln.new(invalid_attributes)
      expect do
        kiln.validate!
      end.to raise_error(Lutaml::Model::ValidationError) do |error|
        expect(error).to include(Lutaml::Model::CollectionCountOutOfRangeError)
        expect(error.error_messages).to include(a_string_matching(/operators count is 0, must be at least 1/))
      end
    end

    it "raises ValidationError containing CollectionCountOutOfRangeError for sensors" do
      kiln = CollectionTests::Kiln.new(attributes.merge(sensors: []))
      expect do
        kiln.validate!
      end.to raise_error(Lutaml::Model::ValidationError) do |error|
        expect(error).to include(Lutaml::Model::CollectionCountOutOfRangeError)
        expect(error.error_messages).to include(a_string_matching(/sensors count is 0, must be between 1 and 3/))
      end
    end
  end

  context "when collection counts are below given ranges" do
    let(:invalid_attributes) do
      attributes.merge(operators: [], sensors: [])
    end

    it "raises CollectionCountOutOfRangeError" do
      kiln = CollectionTests::Kiln.new(invalid_attributes)
      expect do
        kiln.validate!
      end.to raise_error(Lutaml::Model::ValidationError) do |error|
        expect(error).to include(Lutaml::Model::CollectionCountOutOfRangeError)
        expect(error.error_messages).to include(a_string_matching(/operators count is 0, must be at least 1/))
      end
    end
  end

  context "when collection with unbounded maximum exceeds minimum" do
    let(:valid_attributes) do
      attributes.merge(operators: ["John", "Jane", "Jim", "Jessica"])
    end

    it "creates the model without errors" do
      expect { CollectionTests::Kiln.new(valid_attributes) }.not_to raise_error
    end
  end

  context "when deserializing XML with invalid collection counts" do
    let(:invalid_xml) do
      <<~XML
        <kiln brand="Skutt">
          <pot>
            <material>clay</material>
          </pot>
          <pot>
            <material>ceramic</material>
          </pot>
          <pot>
            <material>porcelain</material>
          </pot>
          <temperature>1200</temperature>
          <operator>John</operator>
          <sensor>Temp1</sensor>
          <sensor>Temp2</sensor>
          <sensor>Temp3</sensor>
          <sensor>Temp4</sensor>
        </kiln>
      XML
    end

    it "raises ValidationError containing CollectionCountOutOfRangeError" do
      expect do
        CollectionTests::Kiln.from_xml(invalid_xml).validate!
      end.to raise_error(Lutaml::Model::ValidationError) do |error|
        expect(error).to include(Lutaml::Model::CollectionCountOutOfRangeError)
        expect(error.error_messages).to include(a_string_matching(/pots count is 3, must be between 0 and 2/))
      end
    end
  end

  context "when specifying invalid collection ranges" do
    it "raises an error for a range with only an upper bound" do
      expect do
        Class.new(Lutaml::Model::Serializable) do
          attribute :invalid_range, Lutaml::Model::Type::String, collection: ..3
        end
      end.to raise_error(ArgumentError, /Invalid collection range/)
    end

    it "raises an error for a range where max is less than min" do
      expect do
        Class.new(Lutaml::Model::Serializable) do
          attribute :invalid_range, Lutaml::Model::Type::String,
                    collection: 9..3
        end
      end.to raise_error(ArgumentError, /Invalid collection range/)
    end

    it "raises an error for a negative range" do
      expect do
        Class.new(Lutaml::Model::Serializable) do
          attribute :invalid_range, Lutaml::Model::Type::String,
                    collection: -2..1
        end
      end.to raise_error(ArgumentError, /Invalid collection range/)
    end

    it "allows a range with only a lower bound" do
      expect do
        Class.new(Lutaml::Model::Serializable) do
          attribute :valid_range, Lutaml::Model::Type::String, collection: 1..
        end
      end.not_to raise_error
    end

    it "allows a range with both lower and upper bounds" do
      expect do
        Class.new(Lutaml::Model::Serializable) do
          attribute :valid_range, Lutaml::Model::Type::String, collection: 1..3
        end
      end.not_to raise_error
    end

    it "allows a range with zero as the lower bound" do
      expect do
        Class.new(Lutaml::Model::Serializable) do
          attribute :valid_range, Lutaml::Model::Type::String, collection: 0..3
        end
      end.not_to raise_error
    end
  end
end
