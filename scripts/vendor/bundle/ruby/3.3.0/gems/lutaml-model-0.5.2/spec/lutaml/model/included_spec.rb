require "spec_helper"
require "lutaml/model"

module IncludedSpec
  class Base
    include Lutaml::Model::Serialize

    attribute :text, Lutaml::Model::Type::String
    attribute :id, Lutaml::Model::Type::String
    attribute :name, Lutaml::Model::Type::String

    xml do
      map_content to: :text
      map_attribute "id", to: :id
      map_element "name", to: :name
    end
  end

  class Implementation1
    include Lutaml::Model::Serialize

    attribute :text, Lutaml::Model::Type::String
    attribute :id, Lutaml::Model::Type::String
    attribute :name, Lutaml::Model::Type::String
    attribute :age, Lutaml::Model::Type::Integer

    xml do
      root "impl_one"
      map_content to: :text
      map_attribute "id", to: :id
      map_element "name", to: :name
      map_element "age", to: :age
    end
  end

  class Implementation2
    include Lutaml::Model::Serialize

    attribute :text, Lutaml::Model::Type::String
    attribute :id, Lutaml::Model::Type::String
    attribute :name, Lutaml::Model::Type::String
    attribute :age, Lutaml::Model::Type::Integer

    xml do
      root "impl_two"
      map_content to: :text
      map_attribute "id", to: :id
      map_element "name", to: :name
      map_element "gender", to: :age
    end
  end

  module ParentClass
    include Lutaml::Model::Serialize

    attribute :parent_name, Lutaml::Model::Type::String
    attribute :parent_id, Lutaml::Model::Type::String

    xml do
      root "parent"
      map_attribute "id", to: :parent_id
      map_element "parent_name", to: :parent_name
    end
  end

  module ChildClass
    include ParentClass

    attribute :child_name, Lutaml::Model::Type::String
    attribute :child_type, Lutaml::Model::Type::String
    attribute :child_text, Lutaml::Model::Type::String

    xml do
      root "child"
      map_attribute "type", to: :child_type
      map_element "child_name", to: :child_name
      map_content to: :child_text
    end
  end

  class GrandChildClass
    include ChildClass

    attribute :grandchild_name, Lutaml::Model::Type::String
    attribute :grandchild_version, Lutaml::Model::Type::String
    attribute :grandchild_text, Lutaml::Model::Type::String

    xml do
      root "grandchild"
      map_attribute "version", to: :grandchild_version
      map_element "grandchild_name", to: :grandchild_name
      map_content to: :grandchild_text
    end
  end
end

RSpec.describe "Included" do
  subject(:impl_object) do
    IncludedSpec::Implementation1.new(
      {
        text: "Some text",
        name: "John Doe",
        id: "foobar",
        age: 30,
      },
    )
  end

  let(:expected_xml) do
    '<impl_one id="foobar"><name>John Doe</name><age>30</age>Some text</impl_one>'
  end

  it "uses included module attributes" do
    expect(impl_object.to_xml(pretty: true)).to eq(expected_xml)
  end

  context "with multiple implementing classes" do
    describe "Implementation1" do
      let(:impl1) { IncludedSpec::Implementation1 }

      it "has correct mappings" do
        expect(impl1.mappings_for(:xml).mappings.count).to eq(4)
      end

      it "has correct attributes" do
        expect(impl1.attributes.count).to eq(4)
      end

      it "has correct model" do
        expect(impl1.model).to eq(impl1)
      end
    end

    describe "Implementation2" do
      let(:impl2) { IncludedSpec::Implementation2 }

      it "has correct mappings" do
        expect(impl2.mappings_for(:xml).mappings.count).to eq(4)
      end

      it "has correct attributes" do
        expect(impl2.attributes.count).to eq(4)
      end

      it "has correct model" do
        expect(impl2.model).to eq(impl2)
      end
    end
  end

  context "with nested module inclusion" do
    let(:grandchild) do
      IncludedSpec::GrandChildClass.new(
        parent_name: "Parent Name",
        parent_id: "P123",
        child_name: "Child Name",
        child_type: "Type A",
        child_text: "Child Text",
        grandchild_name: "GrandChild Name",
        grandchild_version: "1.0",
        grandchild_text: "GrandChild Text",
      )
    end

    it "inherits attributes through the chain" do
      expect(IncludedSpec::GrandChildClass.attributes.keys).to include(
        :parent_name, :parent_id,
        :child_name, :child_type, :child_text,
        :grandchild_name, :grandchild_version, :grandchild_text
      )
    end

    it "maintains correct XML mappings through inheritance" do
      expected_xml = <<~XML
        <grandchild id="P123" type="Type A" version="1.0">
          <parent_name>Parent Name</parent_name>
          <child_name>Child Name</child_name>
          <grandchild_name>GrandChild Name</grandchild_name>
          GrandChild Text
        </grandchild>
      XML

      expect(grandchild.to_xml(pretty: true)).to be_equivalent_to(expected_xml)
    end

    it "preserves separate mapping configurations" do
      expect(IncludedSpec::ParentClass.mappings_for(:xml).root_element).to eq("parent")
      expect(IncludedSpec::ChildClass.mappings_for(:xml).root_element).to eq("child")
      expect(IncludedSpec::GrandChildClass.mappings_for(:xml).root_element).to eq("grandchild")
    end
  end
end
