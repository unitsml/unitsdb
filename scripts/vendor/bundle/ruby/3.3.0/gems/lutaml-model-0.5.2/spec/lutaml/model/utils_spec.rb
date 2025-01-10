require "spec_helper"
require "lutaml/model/utils"

RSpec.describe Lutaml::Model::Utils do
  let(:utils) { described_class }

  shared_examples "string conversion" do |method, examples|
    describe ".#{method}" do
      examples.each do |input, expected_output|
        context "when input is #{input.nil? ? 'nil' : "'#{input}'"}" do
          it "returns '#{expected_output}'" do
            expect(utils.send(method, input)).to eq(expected_output)
          end
        end
      end
    end
  end

  camel_case_examples = {
    "hello_world" => "HelloWorld",
    "foo_bar_baz" => "FooBarBaz",
    "" => "",
    nil => "",
    "hello_world/foo_bar_baz" => "HelloWorld::FooBarBaz",
  }

  classify_examples_extra = {
    "hello_world::foo_bar_baz" => "HelloWorld::FooBarBaz",
  }
  classify_examples = camel_case_examples.merge(classify_examples_extra)

  snake_case_examples = {
    "HelloWorld" => "hello_world",
    "FooBarBaz" => "foo_bar_baz",
    "" => "",
    nil => "",
    "HelloWorld::FooBarBaz" => "hello_world/foo_bar_baz",
  }

  include_examples "string conversion", :camel_case, camel_case_examples
  include_examples "string conversion", :classify, classify_examples
  include_examples "string conversion", :snake_case, snake_case_examples

  describe ".deep_dup" do
    let(:original_hash) do
      {
        one: {
          one_one: {
            one_one1: "one",
            one_one2: :two,
          },
          one_two: "12",
        },
      }
    end

    let(:duplicate_hash) { utils.deep_dup(original_hash) }

    it "creates deep duplicate of hash" do
      expect(original_hash).to eq(duplicate_hash)
      expect(original_hash.object_id).not_to eq(duplicate_hash.object_id)

      expect(original_hash[:one]).to eq(duplicate_hash[:one])
      expect(original_hash[:one].object_id).not_to eq(duplicate_hash[:one].object_id)

      expect(original_hash[:one][:one_one]).to eq(duplicate_hash[:one][:one_one])
      expect(original_hash[:one][:one_one].object_id).not_to eq(duplicate_hash[:one][:one_one].object_id)

      expect(original_hash[:one][:one_one][:one_one1]).to eq(duplicate_hash[:one][:one_one][:one_one1])
      expect(original_hash[:one][:one_one][:one_one1].object_id).not_to eq(duplicate_hash[:one][:one_one][:one_one1].object_id)

      # this is a symbol so the object_id will be same
      expect(original_hash[:one][:one_one][:one_one2]).to eq(duplicate_hash[:one][:one_one][:one_one2])

      expect(original_hash[:one][:one_two]).to eq(duplicate_hash[:one][:one_two])
      expect(original_hash[:one][:one_two].object_id).not_to eq(duplicate_hash[:one][:one_two].object_id)
    end
  end
end
