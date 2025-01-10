require "spec_helper"
require_relative "fixtures/sample_model"

RSpec.describe SampleModel do
  let(:model) { described_class.new(attributes) }
  let(:attributes_yaml) do
    {
      "name" => "John Doe",
      "age" => 25,
      "balance" => "100432423.523142344124",
      "tags" => [
        { "text" => "ruby" },
        { "text" => "coding" },
      ],
      "preferences" => { notifications: false, theme: "dark" },
      "status" => "premium",
      "large_number" => 9999,
      "email" => "john@example.com",
      "role" => "admin",
    }
  end
  let(:attributes) do
    {
      name: "John Doe",
      age: 25,
      balance: BigDecimal("100432423.523142344124"),
      tags: [
        SampleModelTag.new(text: "ruby"),
        SampleModelTag.new(text: "coding"),
      ],
      preferences: { notifications: false, theme: "dark" },
      status: "premium",
      large_number: 9999,
      email: "john@example.com",
      role: "admin",
    }
  end

  describe "default values" do
    let(:model) { described_class.new }

    it "sets default name" do
      expect(model.name).to eq("Anonymous")
    end

    it "sets default age" do
      expect(model.age).to eq(18)
    end

    it "sets default balance" do
      expect(model.balance).to eq(BigDecimal("0.0"))
    end

    it "sets default tags" do
      expect(model.tags).to eq([])
    end

    it "sets default preferences" do
      expect(model.preferences).to eq({ notifications: true })
    end

    it "sets default status" do
      expect(model.status).to eq("active")
    end

    it "sets default large_number" do
      expect(model.large_number).to eq(0)
    end

    it "sets default email" do
      expect(model.email).to eq("example@example.com")
    end

    it "sets default role" do
      expect(model.role).to eq("user")
    end
  end

  describe "role validation" do
    it "accepts valid roles" do
      %w[user admin guest].each do |role|
        model.role = role
        expect(model.role).to eq(role)
      end
    end

    it "raises error for invalid role" do
      model.role = "invalid"
      expect { model.validate! }.to raise_error(Lutaml::Model::ValidationError)
    end
  end

  describe "YAML serialization" do
    it "serializes to YAML" do
      expect(model.to_yaml).to eq(attributes_yaml.to_yaml)
    end

    it "deserializes from YAML" do
      yaml = attributes_yaml.to_yaml
      sample = described_class.from_yaml(yaml)

      expect(sample.name).to eq("John Doe")
      expect(sample.age).to eq(25)
      expect(sample.balance).to eq(BigDecimal("100432423.523142344124"))
      expect(sample.tags).to all(be_a(SampleModelTag))
      expect(sample.tags.map(&:text)).to eq(["ruby", "coding"])
      expect(sample.preferences).to eq({ notifications: false, theme: "dark" })
      expect(sample.status).to eq("premium")
      expect(sample.large_number).to eq(9999)
      expect(sample.email).to eq("john@example.com")
      expect(sample.role).to eq("admin")
    end
  end
end
