# frozen_string_literal: true

module ChildMapping
  class Schema < Lutaml::Model::Serializable
    attribute :id, Lutaml::Model::Type::String
    attribute :path, Lutaml::Model::Type::String
    attribute :name, Lutaml::Model::Type::String
  end

  class ChildMappingClass < Lutaml::Model::Serializable
    attribute :schemas, Schema, collection: true

    json do
      map "schemas", to: :schemas,
                     child_mappings: {
                       id: :key,
                       path: %i[path link],
                       name: %i[path name],
                     }
    end

    yaml do
      map "schemas", to: :schemas,
                     child_mappings: {
                       id: :key,
                       path: %i[path link],
                       name: %i[path name],
                     }
    end

    toml do
      map "schemas", to: :schemas,
                     child_mappings: {
                       id: :key,
                       path: %i[path abc],
                       name: %i[path name],
                     }
    end
  end

  class JS < Lutaml::Model::Serializable
    attribute :prop, :string
    attribute :hook, :string

    key_value do
      map :prop, to: :prop
      map :hook, to: :hook
    end
  end

  class Symbol < Lutaml::Model::Serializable
    attribute :ascii, :string
    attribute :html, :string
    attribute :latex, :string
    attribute :unicode, :string
    attribute :js, JS

    key_value do
      map :ascii, to: :ascii
      map :html, to: :html
      map :latex, to: :latex
      map :unicode, to: :unicode
      map :js, to: :js
    end
  end

  class Prefix < Lutaml::Model::Serializable
    attribute :id, :string
    attribute :name, :string
    attribute :symbol, Symbol
    attribute :base, :integer
    attribute :power, :integer

    key_value do
      map :prefix_id, to: :id
      map :name, to: :name
      map :symbol, to: :symbol
      map :base, to: :base
      map :power, to: :power
    end
  end

  class Prefixes < Lutaml::Model::Serializable
    attribute :prefixes, Prefix, collection: true

    key_value do
      map "prefixes", to: :prefixes, child_mappings:
                                      {
                                        id: :key,
                                        name: :name,
                                        symbol: :symbol,
                                        base: :base,
                                        power: :power,
                                      }
    end
  end
end

RSpec.describe ChildMapping do
  let(:mapper) { ChildMapping::ChildMappingClass }
  let(:schema) { ChildMapping::Schema }

  let(:hash) do
    {
      "schemas" => {
        "foo" => {
          "path" => {
            "link" => "link one",
            "name" => "one",
          },
        },
        "abc" => {
          "path" => {
            "link" => "link two",
            "name" => "two",
          },
        },
        "hello" => {
          "path" => {
            "link" => "link three",
            "name" => "three",
          },
        },
      },
    }
  end

  let(:expected_ids) { ["foo", "abc", "hello"] }
  let(:expected_paths) { ["link one", "link two", "link three"] }
  let(:expected_names) { ["one", "two", "three"] }

  let(:prefixes_hash) do
    {
      "prefixes" => {
        "NISTp10_30" => {
          "name" => "quetta",
          "symbol" => {
            "ascii" => "Q",
            "html" => "Q",
            "latex" => "Q",
            "unicode" => "Q",
            "js" => {
              "prop" => "head",
              "hook" => "async",
            },
          },
          "base" => 10,
          "power" => 30,
        },
        "NISTp10_27" => {
          "name" => "ronna",
          "symbol" => {
            "ascii" => "R",
            "html" => "R",
            "latex" => "R",
            "unicode" => "R",
            "js" => {
              "prop" => "head",
              "hook" => "async",
            },
          },
          "base" => 10,
          "power" => 27,
        },
      },
    }
  end

  context "with json" do
    let(:json) do
      hash.to_json
    end

    let(:prefixes_json) do
      prefixes_hash.to_json
    end

    describe ".from_json" do
      it "create model according to json" do
        instance = mapper.from_json(json)

        expect(instance.schemas.count).to eq(3)
        expect(instance.schemas.map(&:id)).to eq(expected_ids)
        expect(instance.schemas.map(&:path)).to eq(expected_paths)
        expect(instance.schemas.map(&:name)).to eq(expected_names)
      end

      it "create model according to json with nesting values" do
        instance = ChildMapping::Prefixes.from_json(prefixes_json)

        expect(instance.prefixes.first.id).to eq("NISTp10_30")
        expect(instance.prefixes.first.symbol.ascii).to eq("Q")
        expect(instance.prefixes.first.symbol.js.hook).to eq("async")
      end
    end

    describe ".to_json" do
      it "converts objects to json" do
        schema1 = schema.new(id: "foo", path: "link one", name: "one")
        schema2 = schema.new(id: "abc", path: "link two", name: "two")
        schema3 = schema.new(id: "hello", path: "link three", name: "three")

        instance = mapper.new(schemas: [schema1, schema2, schema3])

        expect(instance.to_json).to eq(json)
      end

      it "converts object to json with nesting values" do
        instance = ChildMapping::Prefixes.from_json(prefixes_json)
        serialized = instance.to_json

        expect(serialized).to be_equivalent_to(prefixes_json)
      end
    end
  end

  context "with yaml" do
    let(:yaml) do
      hash.to_yaml
    end

    let(:prefixes_yaml) do
      prefixes_hash.to_yaml
    end

    describe ".from_yaml" do
      it "create model according to yaml" do
        instance = mapper.from_yaml(yaml)

        expect(instance.schemas.count).to eq(3)
        expect(instance.schemas.map(&:id)).to eq(expected_ids)
        expect(instance.schemas.map(&:path)).to eq(expected_paths)
        expect(instance.schemas.map(&:name)).to eq(expected_names)
      end

      it "create model according to yaml with nesting values" do
        instance = ChildMapping::Prefixes.from_yaml(prefixes_yaml)

        expect(instance.prefixes.first.id).to eq("NISTp10_30")
        expect(instance.prefixes.first.symbol.ascii).to eq("Q")
        expect(instance.prefixes.first.symbol.js.hook).to eq("async")
      end
    end

    describe ".to_yaml" do
      it "converts objects to yaml" do
        schema1 = schema.new(id: "foo", path: "link one", name: "one")
        schema2 = schema.new(id: "abc", path: "link two", name: "two")
        schema3 = schema.new(id: "hello", path: "link three", name: "three")

        instance = mapper.new(schemas: [schema1, schema2, schema3])

        expect(instance.to_yaml).to eq(yaml)
      end

      it "converts object to yaml with nesting values" do
        instance = ChildMapping::Prefixes.from_yaml(prefixes_yaml)
        serialized = instance.to_yaml

        expect(YAML.safe_load(serialized)).to eq(YAML.safe_load(prefixes_yaml))
      end
    end
  end

  context "with toml" do
    let(:toml) do
      <<~TOML
        [schemas.foo.path]
        abc = "link one"
        name = "one"
        [schemas.abc.path]
        abc = "link two"
        name = "two"
        [schemas.hello.path]
        abc = "link three"
        name = "three"
      TOML
    end

    let(:prefixes_toml) do
      <<~TOML
        [prefixes.NISTp10_30]
        name = "quetta"
        base = 10
        power = 30

        [prefixes.NISTp10_30.symbol]
        ascii = "Q"
        html = "Q"
        latex = "Q"
        unicode = "Q"

        [prefixes.NISTp10_30.symbol.js]
        prop = "head"
        hook = "async"

        [prefixes.NISTp10_27]
        name = "ronna"
        base = 10
        power = 27

        [prefixes.NISTp10_27.symbol]
        ascii = "R"
        html = "R"
        latex = "R"
        unicode = "R"

        [prefixes.NISTp10_27.symbol.js]
        prop = "head"
        hook = "async"
      TOML
    end

    describe ".from_toml" do
      it "create model according to toml" do
        instance = mapper.from_toml(toml)

        expect(instance.schemas.count).to eq(3)
        expect(instance.schemas.map(&:id)).to eq(expected_ids)
        expect(instance.schemas.map(&:path)).to eq(expected_paths)
        expect(instance.schemas.map(&:name)).to eq(expected_names)
      end

      it "create model according to toml with nesting values" do
        instance = ChildMapping::Prefixes.from_toml(prefixes_toml)

        expect(instance.prefixes.first.id).to eq("NISTp10_30")
        expect(instance.prefixes.first.symbol.ascii).to eq("Q")
        expect(instance.prefixes.first.symbol.js.hook).to eq("async")
      end
    end

    describe ".to_toml" do
      it "converts objects to toml" do
        schema1 = schema.new(id: "foo", path: "link one", name: "one")
        schema2 = schema.new(id: "abc", path: "link two", name: "two")
        schema3 = schema.new(id: "hello", path: "link three", name: "three")

        instance = mapper.new(schemas: [schema1, schema2, schema3])

        actual = Lutaml::Model::Config.toml_adapter.parse(instance.to_toml)
        expected = Lutaml::Model::Config.toml_adapter.parse(toml)

        expect(actual.attributes).to eq(expected.attributes)
      end

      it "converts object to toml with nesting values" do
        instance = ChildMapping::Prefixes.from_toml(prefixes_toml)
        actual = Lutaml::Model::Config.toml_adapter.parse(instance.to_toml)
        expected = Lutaml::Model::Config.toml_adapter.parse(prefixes_toml)

        expect(actual.attributes).to eq(expected.attributes)
      end
    end
  end
end
