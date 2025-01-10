require "spec_helper"

RSpec.describe Lutaml::Model::Type::String do
  describe ".cast" do
    subject(:cast) { described_class.cast(value) }

    context "with nil value" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "with string value" do
      let(:value) { "test" }

      it { is_expected.to eq("test") }
    end

    context "with symbol" do
      let(:value) { :symbol }

      it { is_expected.to eq("symbol") }
    end

    context "with integer" do
      let(:value) { 123 }

      it { is_expected.to eq("123") }
    end

    context "with float" do
      let(:value) { 123.45 }

      it { is_expected.to eq("123.45") }
    end

    context "with true" do
      let(:value) { true }

      it { is_expected.to eq("true") }
    end

    context "with false" do
      let(:value) { false }

      it { is_expected.to eq("false") }
    end

    context "with Date object" do
      let(:value) { Date.new(2024, 1, 1) }

      it { is_expected.to eq("2024-01-01") }
    end

    context "with Time object" do
      let(:value) { Time.new(2024, 1, 1, 12, 0, 0, "+00:00") }

      it { is_expected.to match(/\A2024-01-01 12:00:00/) }
    end

    context "with array" do
      let(:value) { [1, 2, 3] }

      it { is_expected.to eq("[1, 2, 3]") }
    end

    context "with hash" do
      let(:value) { { a: 1, b: 2 } }
      let(:expected_value) do
        if RUBY_VERSION < "3.4.0"
          "{:a=>1, :b=>2}"
        else
          "{a: 1, b: 2}"
        end
      end

      it { is_expected.to eq(expected_value) }
    end

    context "with object responding to to_s" do
      let(:value) do
        Class.new do
          def to_s
            "custom string"
          end
        end.new
      end

      it { is_expected.to eq("custom string") }
    end

    context "with empty string" do
      let(:value) { "" }

      it { is_expected.to eq("") }
    end

    context "with whitespace string" do
      let(:value) { "  \t\n  " }

      it { is_expected.to eq("  \t\n  ") }
    end
  end

  describe ".serialize" do
    subject(:serialize) { described_class.serialize(value) }

    context "with nil value" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "with string value" do
      let(:value) { "test" }

      it { is_expected.to eq("test") }
    end

    context "with empty string" do
      let(:value) { "" }

      it { is_expected.to eq("") }
    end

    context "with whitespace string" do
      let(:value) { "  \t\n  " }

      it { is_expected.to eq("  \t\n  ") }
    end

    context "with string containing special characters" do
      let(:value) { "test\u0000test" }

      it { is_expected.to eq("test\u0000test") }
    end

    context "with unicode characters" do
      let(:value) { "こんにちは" }

      it { is_expected.to eq("こんにちは") }
    end

    context "with emoji" do
      let(:value) { "Hello 👋" }

      it { is_expected.to eq("Hello 👋") }
    end
  end
end
