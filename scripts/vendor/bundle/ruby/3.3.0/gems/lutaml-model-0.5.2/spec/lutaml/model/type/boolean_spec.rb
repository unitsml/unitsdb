require "spec_helper"

module BooleanSpec
  class Employee < Lutaml::Model::Serializable
    attribute :name, :string
    attribute :full_time, :boolean
    attribute :on_leave, :boolean
    attribute :remote, :boolean
    attribute :active, :boolean

    key_value do
      map "name", to: :name
      map "full_time", to: :full_time
      map "on_leave", to: :on_leave
      map "remote", to: :remote, render_nil: true
      map "active", to: :active, render_nil: false
    end
  end
end

RSpec.describe Lutaml::Model::Type::Boolean do
  describe ".cast" do
    let(:truthy_values) { [true, "true", "t", "yes", "y", "1"] }
    let(:falsey_values) { [false, "false", "f", "no", "n", "0"] }

    it "returns nil for nil input" do
      expect(described_class.cast(nil)).to be_nil
    end

    context "with truthy values" do
      it "casts to true" do
        truthy_values.each do |value|
          expect(described_class.cast(value)).to be true
        end
      end
    end

    context "with falsey values" do
      it "casts to false" do
        falsey_values.each do |value|
          expect(described_class.cast(value)).to be false
        end
      end
    end

    context "with other values" do
      it "returns the original value" do
        value = "other"
        expect(described_class.cast(value)).to eq value
      end
    end
  end

  describe ".serialize" do
    it "returns nil for nil input" do
      expect(described_class.serialize(nil)).to be_nil
    end

    it "returns true for truthy input" do
      expect(described_class.serialize(true)).to be true
    end

    it "returns false for falsey input" do
      expect(described_class.serialize(false)).to be false
    end

    it "preserves input boolean values" do
      expect(described_class.serialize(false)).to be false
      expect(described_class.serialize(true)).to be true
    end
  end

  context "with key-value serialization" do
    let(:yaml) do
      {
        "name" => "John Smith",
        "full_time" => true,
        "on_leave" => false,
        "remote" => nil,
        "active" => nil,
      }.to_yaml
    end

    let(:expected_yaml) do
      {
        "name" => "John Smith",
        "full_time" => true,
        "on_leave" => false,
        "remote" => nil,
      }.to_yaml
    end

    it "deserializes boolean values correctly" do
      employee = BooleanSpec::Employee.from_yaml(yaml)

      expect(employee.name).to eq("John Smith")
      expect(employee.full_time).to be true
      expect(employee.on_leave).to be false
      expect(employee.remote).to be_nil
      expect(employee.active).to be_nil
    end

    it "serializes boolean values correctly" do
      employee = BooleanSpec::Employee.new(
        name: "John Smith",
        full_time: true,
        on_leave: false,
        remote: nil,
        active: nil,
      )

      yaml_output = employee.to_yaml
      expect(yaml_output).to eq(expected_yaml)
    end
  end
end
