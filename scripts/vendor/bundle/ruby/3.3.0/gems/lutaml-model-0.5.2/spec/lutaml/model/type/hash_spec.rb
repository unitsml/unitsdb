require "spec_helper"

RSpec.describe Lutaml::Model::Type::Hash do
  describe ".cast" do
    it "returns nil for nil input" do
      expect(described_class.cast(nil)).to be_nil
    end

    it "returns text content from hash with only text key" do
      hash = { "text" => "content" }
      expect(described_class.cast(hash)).to eq "content"
    end

    it "normalizes MappingHash to regular Hash" do
      mapping_hash = Lutaml::Model::MappingHash.new
      mapping_hash["key"] = "value"
      expect(described_class.cast(mapping_hash)).to eq({ "key" => "value" })
    end

    it "filters out text keys from nested hashes" do
      hash = {
        "key1" => {
          "text" => "content1",
          "other" => "value1",
        },
        "key2" => {
          "text" => "content2",
          "other" => "value2",
        },
      }
      expected = {
        "key1" => { "other" => "value1" },
        "key2" => { "other" => "value2" },
      }
      expect(described_class.cast(hash)).to eq expected
    end

    it "preserves non-hash values" do
      input = {
        "string" => "value",
        "number" => 42,
        "array" => [1, 2, 3],
      }
      expect(described_class.cast(input)).to eq input
    end
  end

  describe ".serialize" do
    it "returns nil for nil input" do
      expect(described_class.serialize(nil)).to be_nil
    end

    it "converts hash to hash" do
      hash = { "key" => "value" }
      expect(described_class.serialize(hash)).to eq hash
    end

    it "converts arbitrary object responding to to_h" do
      obj = double(to_h: { "key" => "value" })
      expect(described_class.serialize(obj)).to eq({ "key" => "value" })
    end
  end
end
