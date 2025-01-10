require "spec_helper"

class TestSerializable < Lutaml::Model::Serializable
  attribute :name, :string, values: ["Alice", "Bob", "Charlie"]
  attribute :email, :string, pattern: /.*?\S+@.+\.\S+/
  attribute :age, :integer, collection: 1..3

  xml do
    root "test"
    map_element "name", to: :name
    map_element "age", to: :age
  end

  json do
    map "name", to: :name
    map "age", to: :age
  end

  yaml do
    map "name", to: :name
    map "age", to: :age
  end

  toml do
    map "name", to: :name
    map "age", to: :age
  end
end

RSpec.describe Lutaml::Model::Serializable do
  let(:valid_instance) do
    TestSerializable.new(name: "Alice", age: [30], email: "alice@gmail.com")
  end

  let(:invalid_instance) do
    TestSerializable.new(name: "David", age: [25, 30, 35, 40], email: "david@gmail")
  end

  describe "serialization methods" do
    it "does not raise validation errors when calling to_xml" do
      expect { invalid_instance.to_xml }.not_to raise_error
    end

    it "does not raise validation errors when calling to_json" do
      expect { invalid_instance.to_json }.not_to raise_error
    end

    it "does not raise validation errors when calling to_yaml" do
      expect { invalid_instance.to_yaml }.not_to raise_error
    end

    it "does not raise validation errors when calling to_toml" do
      expect { invalid_instance.to_toml }.not_to raise_error
    end
  end

  describe "setting attributes" do
    it "does not raise validation errors when setting valid attributes" do
      expect { valid_instance.name = "Bob" }.not_to raise_error
      expect { valid_instance.age = [25, 30] }.not_to raise_error
    end

    it "does not raise validation errors when setting invalid attributes" do
      expect { invalid_instance.name = "David" }.not_to raise_error
      expect { invalid_instance.age = [25, 30, 35, 40] }.not_to raise_error
    end
  end

  describe "validate method" do
    it "returns errors for invalid attributes" do
      errors = invalid_instance.validate
      expect(errors).not_to be_empty
      expect(errors[0]).to be_a(Lutaml::Model::InvalidValueError)
      expect(errors[1]).to be_a(Lutaml::Model::PatternNotMatchedError)
      expect(errors[2]).to be_a(Lutaml::Model::CollectionCountOutOfRangeError)
    end
  end

  describe "validate! method" do
    it "raises ValidationError for invalid attributes" do
      expect do
        invalid_instance.validate!
      end.to raise_error(Lutaml::Model::ValidationError)
    end

    it "does not raise ValidationError for valid attributes" do
      expect { valid_instance.validate! }.not_to raise_error
    end
  end
end
