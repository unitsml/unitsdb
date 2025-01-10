# spec/lutaml/model/validation_spec.rb

require "spec_helper"

RSpec.describe Lutaml::Model::Validation do
  class ValidationTestClass < Lutaml::Model::Serializable
    attribute :name, :string
    attribute :age, :integer
    attribute :email, :string, values: ["test@example.com", "user@example.com"]
    attribute :tags, :string, collection: true
    attribute :role, :string, collection: 1..3
  end

  let(:valid_instance) do
    ValidationTestClass.new(
      name: "John Doe",
      age: 30,
      email: "test@example.com",
      tags: ["tag1", "tag2"],
      role: ["admin"],
    )
  end

  describe "#validate" do
    it "returns an empty array for a valid instance" do
      expect(valid_instance.validate).to be_empty
    end

    xit "returns errors for invalid integer value" do
      instance = ValidationTestClass.new(age: "thirty", role: ["admin"])
      errors = instance.validate
      expect(errors).to include("Invalid value for attribute age: thirty")
    end

    it "returns errors for value not in allowed set" do
      instance = ValidationTestClass.new(email: "invalid@example.com",
                                         role: ["admin"])
      expect do
        instance.validate!
      end.to raise_error(Lutaml::Model::ValidationError) do |error|
        expect(error.error_messages.join("\n")).to include("email is `invalid@example.com`, must be one of the following [test@example.com, user@example.com]")
      end
    end

    it "returns errors for invalid collection count" do
      instance = ValidationTestClass.new(role: ["admin", "user", "manager",
                                                "guest"])
      expect do
        instance.validate!
      end.to raise_error(Lutaml::Model::ValidationError) do |error|
        expect(error.error_messages.join("\n")).to include("role count is 4, must be between 1 and 3")
      end
    end

    xit "returns multiple errors for multiple invalid attributes" do
      instance = ValidationTestClass.new(name: "123", age: "thirty",
                                         email: "invalid@example.com", role: [])
      expect do
        instance.validate!
      end.to raise_error(Lutaml::Model::ValidationError) do |error|
        expect(error.error_messages.join("\n")).to include("Invalid value for attribute age: thirty")
        expect(error.error_messages.join("\n")).to include("email is `invalid@example.com`, must be one of the following [test@example.com, user@example.com]")
        expect(error.error_messages.join("\n")).to include("role count is 0, must be between 1 and 3")
      end
    end
  end

  describe "#validate!" do
    it "does not raise an error for a valid instance" do
      expect { valid_instance.validate! }.not_to raise_error
    end

    xit "raises a ValidationError with all error messages for an invalid instance" do
      instance = ValidationTestClass.new(name: "test", age: "thirty")
      expect do
        instance.validate!
      end.to raise_error(Lutaml::Model::ValidationError) do |error|
        expect(error.error_messages.join("\n")).to include("role count is 0, must be between 1 and 3")
        expect(error.error_messages.join("\n")).to include("Invalid value for attribute age: thirty")
      end
    end
  end
end
