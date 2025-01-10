module RootMappingSpec
  class CeramicDetails < Lutaml::Model::Serializable
    attribute :name, :string
    attribute :insignia, :string

    key_value do
      map "name", to: :name
      map "insignia", to: :insignia
    end
  end

  class CeramicWithDetails < Lutaml::Model::Serializable
    attribute :ceramic_id, :string
    attribute :ceramic_type, :string
    attribute :ceramic_details, CeramicDetails
    attribute :ceramic_urn, :string

    key_value do
      map "id", to: :ceramic_id
      map "type", to: :ceramic_type
      map "details", to: :ceramic_details
      map "urn", to: :ceramic_urn
    end
  end

  class CeramicCollectionWithKeyAndValue < Lutaml::Model::Serializable
    attribute :ceramics, CeramicWithDetails, collection: true

    key_value do
      map to: :ceramics,
          root_mappings: {
            ceramic_id: :key,
            ceramic_details: :value,
          }
    end
  end

  class CeramicCollectionWithKeyAndComplexValue < Lutaml::Model::Serializable
    attribute :ceramics, CeramicWithDetails, collection: true

    key_value do
      map to: :ceramics,
          root_mappings: {
            ceramic_id: :key,
            ceramic_type: :type,
            ceramic_details: "details",
            ceramic_urn: ["urn", "primary"],
          }
    end
  end

  class Ceramic < Lutaml::Model::Serializable
    attribute :ceramic_id, :string
    attribute :ceramic_name, :string

    key_value do
      map "id", to: :ceramic_id
      map "name", to: :ceramic_name
    end
  end

  class CeramicCollectionWithKeyOnly < Lutaml::Model::Serializable
    attribute :ceramics, Ceramic, collection: true

    key_value do
      map to: :ceramics, root_mappings: { ceramic_id: :key }
    end
  end

  class CeramicCollectionWithoutCollectionTrue < Lutaml::Model::Serializable
    attribute :ceramics, Ceramic

    key_value do
      map to: :ceramics, root_mappings: { ceramic_id: :key }
    end
  end
end

RSpec.describe "RootMapping" do
  shared_examples "having root mappings" do |format|
    let(:adapter) do
      Lutaml::Model::Config.public_send(:"#{format}_adapter")
    end

    let(:input) do
      adapter.new(input_hash).public_send(:"to_#{format}")
    end

    # 1. Only map to `:key`. Then only override key, the rest of the mappings stay.
    context "when only `key` is mapped" do
      let(:parsed) do
        RootMappingSpec::CeramicCollectionWithKeyOnly.public_send(:"from_#{format}", input)
      end

      let(:input_hash) do
        {
          "vase1" => { "name" => "Imperial Vase" },
          "bowl2" => { "name" => "18th Century Bowl" },
        }
      end

      let(:ceramic_vase) do
        RootMappingSpec::Ceramic.new(
          ceramic_id: "vase1",
          ceramic_name: "Imperial Vase",
        )
      end

      let(:ceramic_bowl) do
        RootMappingSpec::Ceramic.new(
          ceramic_id: "bowl2",
          ceramic_name: "18th Century Bowl",
        )
      end

      it "parses" do
        expect(parsed.ceramics.count).to eq(2)
        # Because Tomlib reverses the order of the hash, so can not check based on position
        expect(parsed.ceramics).to include(ceramic_vase)
        expect(parsed.ceramics).to include(ceramic_bowl)
      end

      describe "serialize" do
        let(:collection) do
          RootMappingSpec::CeramicCollectionWithKeyOnly.new(ceramics: [
                                                              ceramic_vase,
                                                              ceramic_bowl,
                                                            ])
        end

        it "serializes correctly" do
          expect(collection.public_send(:"to_#{format}")).to eq(input)
        end
      end
    end

    # 2. Maps `:key` and another attribute, then we override all the other mappings (clean slate)
    context "when `key` and `value` are mapped" do
      let(:parsed) do
        RootMappingSpec::CeramicCollectionWithKeyAndValue.public_send(:"from_#{format}", input)
      end

      let(:input_hash) do
        {
          "vase1" => { "name" => "Imperial Vase", "insignia" => "Tang Tianbao" },
          "bowl2" => { "name" => "18th Century Bowl", "insignia" => "Ming Wanli" },
        }
      end

      let(:vase_with_details) do
        RootMappingSpec::CeramicWithDetails.new(
          ceramic_id: "vase1",
          ceramic_details: RootMappingSpec::CeramicDetails.new(
            name: "Imperial Vase",
            insignia: "Tang Tianbao",
          ),
        )
      end

      let(:bowl_with_details) do
        RootMappingSpec::CeramicWithDetails.new(
          ceramic_id: "bowl2",
          ceramic_details: RootMappingSpec::CeramicDetails.new(
            name: "18th Century Bowl",
            insignia: "Ming Wanli",
          ),
        )
      end

      it "parses" do
        expect(parsed.ceramics.count).to eq(2)
        # Because Tomlib reverses the order of the hash, so can not check based on position
        expect(parsed.ceramics).to include(vase_with_details)
        expect(parsed.ceramics).to include(bowl_with_details)
      end

      describe "serialize" do
        let(:collection) do
          RootMappingSpec::CeramicCollectionWithKeyAndValue.new(ceramics: [
                                                                  vase_with_details,
                                                                  bowl_with_details,
                                                                ])
        end

        it "serializes correctly" do
          expect(collection.public_send(:"to_#{format}")).to eq(input)
        end
      end
    end

    # 3. Maps `:key` and `:value`, then we map the key and the value body to the new mappings.
    context "when `key` and complex value structure is mapped" do
      let(:parsed) do
        RootMappingSpec::CeramicCollectionWithKeyAndComplexValue.public_send(:"from_#{format}", input)
      end

      let(:input_hash) do
        {
          "vase1" => {
            "type" => "vase",
            "details" => {
              "name" => "Imperial Vase",
              "insignia" => "Tang Tianbao",
            },
            "urn" => {
              "primary" => "urn:ceramic:vase:vase1",
            },
          },
          "bowl2" => {
            "type" => "bowl",
            "details" => {
              "name" => "18th Century Bowl",
              "insignia" => "Ming Wanli",
            },
            "urn" => {
              "primary" => "urn:ceramic:bowl:bowl2",
            },
          },
        }
      end

      let(:vase_with_details) do
        RootMappingSpec::CeramicWithDetails.new(
          ceramic_id: "vase1",
          ceramic_type: "vase",
          ceramic_urn: "urn:ceramic:vase:vase1",
          ceramic_details: RootMappingSpec::CeramicDetails.new(
            name: "Imperial Vase",
            insignia: "Tang Tianbao",
          ),
        )
      end

      let(:bowl_with_details) do
        RootMappingSpec::CeramicWithDetails.new(
          ceramic_id: "bowl2",
          ceramic_type: "bowl",
          ceramic_urn: "urn:ceramic:bowl:bowl2",
          ceramic_details: RootMappingSpec::CeramicDetails.new(
            name: "18th Century Bowl",
            insignia: "Ming Wanli",
          ),
        )
      end

      it "parses" do
        expect(parsed.ceramics.count).to eq(2)
        # Because Tomlib reverses the order of the hash, so can not check based on position
        expect(parsed.ceramics).to include(vase_with_details)
        expect(parsed.ceramics).to include(bowl_with_details)
      end

      describe "serialize from object" do
        let(:collection) do
          RootMappingSpec::CeramicCollectionWithKeyAndComplexValue.new(ceramics: [
                                                                         vase_with_details,
                                                                         bowl_with_details,
                                                                       ])
        end

        it "serializes correctly" do
          expect(collection.public_send(:"to_#{format}")).to eq(input)
        end
      end
    end

    context "when `collection: true` is missing" do
      let(:input_hash) do
        {
          "vase1" => { "name" => "Imperial Vase" },
          "bowl2" => { "name" => "18th Century Bowl" },
        }
      end

      it "raises error" do
        expect do
          RootMappingSpec::CeramicCollectionWithoutCollectionTrue.public_send(:"from_#{format}", input)
        end.to raise_error(
          Lutaml::Model::CollectionTrueMissingError,
          "May be `collection: true` is missing for `ceramics` in RootMappingSpec::CeramicCollectionWithoutCollectionTrue",
        )
      end
    end
  end

  describe Lutaml::Model::YamlAdapter::StandardYamlAdapter do
    it_behaves_like "having root mappings", :yaml
  end

  describe Lutaml::Model::JsonAdapter::StandardJsonAdapter do
    it_behaves_like "having root mappings", :json
  end

  describe Lutaml::Model::TomlAdapter::TomlRbAdapter do
    it_behaves_like "having root mappings", :toml
  end
end
