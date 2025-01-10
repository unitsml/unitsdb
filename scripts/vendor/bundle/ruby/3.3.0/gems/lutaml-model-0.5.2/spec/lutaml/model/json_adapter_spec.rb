require "spec_helper"
require "lutaml/model/json_adapter/standard_json_adapter"
require "lutaml/model/json_adapter/multi_json_adapter"
require_relative "../../fixtures/sample_model"

RSpec.shared_examples "a JSON adapter" do |adapter_class|
  let(:attributes) { { name: "John Doe", age: 30 } }
  let(:model) { SampleModel.new(attributes) }

  let(:expected_json) do
    if adapter_class == Lutaml::Model::JsonAdapter::StandardJsonAdapter
      JSON.generate(attributes)
    elsif adapter_class == Lutaml::Model::JsonAdapter::MultiJsonAdapter
      MultiJson.dump(attributes)
    end
  end

  it "serializes to JSON" do
    json = adapter_class.new(attributes).to_json
    expect(json).to eq(expected_json)
  end

  it "deserializes from JSON" do
    doc = adapter_class.parse(expected_json)
    new_model = SampleModel.new(doc.to_h)
    expect(new_model.name).to eq("John Doe")
    expect(new_model.age).to eq(30)
  end
end

RSpec.describe Lutaml::Model::JsonAdapter::StandardJsonAdapter do
  it_behaves_like "a JSON adapter", described_class
end

RSpec.describe Lutaml::Model::JsonAdapter::MultiJsonAdapter do
  it_behaves_like "a JSON adapter", described_class
end
