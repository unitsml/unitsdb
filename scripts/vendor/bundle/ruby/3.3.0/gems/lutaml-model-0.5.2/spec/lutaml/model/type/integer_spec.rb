require "spec_helper"

RSpec.describe Lutaml::Model::Type::Integer do
  describe ".cast" do
    subject(:cast) { described_class.cast(value) }

    context "with nil value" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "with integer" do
      let(:value) { 123 }

      it { is_expected.to eq(123) }
    end

    context "with integer string" do
      let(:value) { "123" }

      it { is_expected.to eq(123) }
    end

    context "with negative integer string" do
      let(:value) { "-123" }

      it { is_expected.to eq(-123) }
    end

    context "with float" do
      let(:value) { 123.45 }

      it { is_expected.to eq(123) }
    end

    context "with float string" do
      let(:value) { "123.45" }

      it { is_expected.to eq(123) }
    end

    context "with exponential notation" do
      let(:value) { "1.23e2" }

      it { is_expected.to eq(123) }
    end

    context "with negative exponential notation" do
      let(:value) { "-1.23e2" }

      it { is_expected.to eq(-123) }
    end

    context "with string containing a leading zero represents octal" do
      let(:value) { "0123" }

      it { is_expected.to eq(83) }
    end

    context "with plus sign" do
      let(:value) { "+123" }

      it { is_expected.to eq(123) }
    end

    context "with whitespace" do
      let(:value) { " 123 " }

      it { is_expected.to eq(123) }
    end

    context "with boolean true" do
      let(:value) { true }

      it { is_expected.to eq(1) }
    end

    context "with boolean false" do
      let(:value) { false }

      it { is_expected.to eq(0) }
    end

    context "with invalid string" do
      let(:value) { "not an integer" }

      it { is_expected.to be_nil }
    end

    context "with very large integer" do
      let(:max_value) { ((2**((0.size * 8) - 2)) - 1) }
      let(:value) { max_value.to_s }

      xit { is_expected.to eq(max_value) }
    end

    context "with very small integer" do
      let(:min_value) { -(2**((0.size * 8) - 2)) }
      let(:value) { min_value.to_s }

      it { is_expected.to eq(min_value) }
    end
  end

  describe ".serialize" do
    subject(:serialize) { described_class.serialize(value) }

    context "with nil value" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "with positive integer" do
      let(:value) { 123 }

      it { is_expected.to eq(123) }
    end

    context "with negative integer" do
      let(:value) { -123 }

      it { is_expected.to eq(-123) }
    end

    context "with zero" do
      let(:value) { 0 }

      it { is_expected.to eq(0) }
    end

    context "with maximum integer" do
      let(:value) { 9223372036854775807 }

      it { is_expected.to eq(9223372036854775807) }
    end

    context "with minimum integer" do
      let(:value) { -9223372036854775808 }

      it { is_expected.to eq(-9223372036854775808) }
    end
  end
end
