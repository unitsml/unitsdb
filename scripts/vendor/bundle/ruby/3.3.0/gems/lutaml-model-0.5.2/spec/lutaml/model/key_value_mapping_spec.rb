require "spec_helper"
require_relative "../../../lib/lutaml/model/key_value_mapping"
require_relative "../../../lib/lutaml/model/key_value_mapping_rule"

RSpec.describe Lutaml::Model::KeyValueMapping do
  let(:mapping) { described_class.new }

  context "with delegate option" do
    before do
      mapping.map("type", to: :type, delegate: :some_delegate)
      mapping.map("name", to: :name)
    end

    it "adds mappings with delegate option" do
      expect(mapping.mappings.size).to eq(2)
      expect(mapping.mappings[0].name).to eq("type")
      expect(mapping.mappings[0].delegate).to eq(:some_delegate)
      expect(mapping.mappings[1].name).to eq("name")
      expect(mapping.mappings[1].delegate).to be_nil
    end
  end

  describe "#deep_dup" do
    before do
      mapping.map(
        "type",
        to: :type,
        render_nil: true,
        delegate: :some_delegate,
        child_mappings: {
          id: :key,
          path: %i[path link],
          name: %i[path name],
        },
      )

      mapping.map(
        "name",
        with: {
          from: :model_from_json,
          to: :json_from_model,
        },
      )
    end

    let(:dup_mapping) { mapping.deep_dup }

    it "creates a deep duplicate" do
      expect(dup_mapping.object_id).not_to eq(mapping.object_id)
    end

    it "correctly duplicates mapping with `to:`" do
      m = mapping.mappings[0]
      dup_m = dup_mapping.mappings[0]

      expect(m.name).to eq(dup_m.name)
      expect(m.name.object_id).not_to eq(dup_m.name.object_id)

      # using symbols so object_id will remain same
      expect(m.to).to eq(dup_m.to)

      # render_nil is boolean so is constant with same object_id
      expect(m.render_nil).to eq(dup_m.render_nil)

      # using symbols so object_id will remain same
      expect(m.delegate).to eq(dup_m.delegate)

      expect(m.child_mappings).to eq(dup_m.child_mappings)
      expect(m.child_mappings.object_id).not_to eq(dup_m.child_mappings.object_id)
    end

    it "correctly duplicates mapping with custom methods" do
      m = mapping.mappings[0]
      dup_m = dup_mapping.mappings[0]

      expect(m.name).to eq(dup_m.name)
      expect(m.name.object_id).not_to eq(dup_m.name.object_id)

      # render_nil is boolean so is constant with same object_id
      expect(m.render_nil).to eq(dup_m.render_nil)

      expect(m.custom_methods).to eq(dup_m.custom_methods)
      expect(m.custom_methods.object_id).not_to eq(dup_m.custom_methods.object_id)
    end
  end
end
