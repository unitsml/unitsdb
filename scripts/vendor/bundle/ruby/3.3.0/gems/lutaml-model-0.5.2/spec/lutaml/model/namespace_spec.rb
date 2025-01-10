require "spec_helper"

module NamespaceSpec
  class NestedChild < Lutaml::Model::Serializable
    attribute :name, :string

    xml do
      root "NestedChild"

      map_element :name, to: :name
    end
  end

  class Child < Lutaml::Model::Serializable
    attribute :nested_child, NestedChild

    xml do
      root "NestedChild"

      map_element :NestedChild, to: :nested_child
    end
  end

  class Parent < Lutaml::Model::Serializable
    attribute :child, Child

    xml do
      root "Parent"
      namespace "https://abc.com"

      map_element :Child, to: :child
    end
  end
end

RSpec.describe "NamespaceSpec" do
  let(:parsed) { NamespaceSpec::Parent.from_xml(xml) }
  let(:xml) do
    <<~XML
      <Parent xmlns="https://abc.com">
        <Child>
          <NestedChild>
            <name>Rogger moore</name>
          </NestedChild>
        </Child>
      </Parent>
    XML
  end

  it "parses nested child using root namespace" do
    expect(parsed.child.nested_child.name).to eq("Rogger moore")
  end

  it "round-trips xml" do
    expect(parsed.to_xml).to be_equivalent_to(xml)
  end
end
