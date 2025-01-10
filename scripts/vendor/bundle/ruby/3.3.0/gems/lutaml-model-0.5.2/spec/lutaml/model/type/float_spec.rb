require "spec_helper"

RSpec.describe Lutaml::Model::Type::Float do
  describe ".cast" do
    subject(:cast) { described_class.cast(value) }

    context "with nil value" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "with float" do
      let(:value) { 123.45 }

      it { is_expected.to eq(123.45) }
    end

    context "with integer" do
      let(:value) { 123 }

      it { is_expected.to eq(123.0) }
    end

    context "with float string" do
      let(:value) { "123.45" }

      it { is_expected.to eq(123.45) }
    end

    context "with integer string" do
      let(:value) { "123" }

      it { is_expected.to eq(123.0) }
    end

    context "with negative float" do
      let(:value) { -123.45 }

      it { is_expected.to eq(-123.45) }
    end

    context "with negative float string" do
      let(:value) { "-123.45" }

      it { is_expected.to eq(-123.45) }
    end

    context "with exponential notation" do
      let(:value) { "1.2345e2" }

      it { is_expected.to eq(123.45) }
    end

    context "with negative exponential notation" do
      let(:value) { "-1.2345e2" }

      it { is_expected.to eq(-123.45) }
    end

    context "with very small exponential notation" do
      let(:value) { "1.2345e-2" }

      it { is_expected.to eq(0.012345) }
    end

    context "with string containing leading zeros" do
      let(:value) { "000123.45" }

      it { is_expected.to eq(123.45) }
    end

    context "with trailing zeros" do
      let(:value) { "123.4500" }

      it { is_expected.to eq(123.45) }
    end

    context "with plus sign" do
      let(:value) { "+123.45" }

      it { is_expected.to eq(123.45) }
    end

    context "with whitespace" do
      let(:value) { " 123.45 " }

      it { is_expected.to eq(123.45) }
    end

    context "with invalid string" do
      let(:value) { "not a float" }

      it { is_expected.to eq(0.0) }
    end

    context "with special float values" do
      it "handles infinity" do
        expect(described_class.cast(Float::INFINITY)).to eq(Float::INFINITY)
        expect(described_class.cast(-Float::INFINITY)).to eq(-Float::INFINITY)
      end

      it "handles NaN" do
        expect(described_class.cast(Float::NAN)).to be_nan
      end
    end

    context "with very large numbers" do
      let(:value) { "1.23456789e100" }

      it { is_expected.to eq(1.23456789e100) }
    end

    context "with very small numbers" do
      let(:value) { "1.23456789e-100" }

      it { is_expected.to eq(1.23456789e-100) }
    end

    context "with precision edge cases" do
      it "handles floating point precision" do
        expect(described_class.cast(0.1 + 0.2)).to be_within(0.0000001).of(0.3)
      end
    end
  end

  describe ".serialize" do
    subject(:serialize) { described_class.serialize(value) }

    context "with nil value" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "with positive float" do
      let(:value) { 123.45 }

      it { is_expected.to eq(123.45) }
    end

    context "with negative float" do
      let(:value) { -123.45 }

      it { is_expected.to eq(-123.45) }
    end

    context "with zero" do
      let(:value) { 0.0 }

      it { is_expected.to eq(0.0) }
    end

    context "with integer-like float" do
      let(:value) { 123.0 }

      it { is_expected.to eq(123.0) }
    end

    context "with very small number" do
      let(:value) { 0.000000123 }

      it { is_expected.to eq(0.000000123) }
    end

    context "with very large number" do
      let(:value) { 1.23e100 }

      it { is_expected.to eq(1.23e100) }
    end

    context "with special float values" do
      it "serializes infinity" do
        expect(described_class.serialize(Float::INFINITY)).to eq(Float::INFINITY)
        expect(described_class.serialize(-Float::INFINITY)).to eq(-Float::INFINITY)
      end

      it "serializes NaN" do
        expect(described_class.serialize(Float::NAN)).to be_nan
      end
    end

    context "with maximum precision" do
      let(:value) { 123.456789123456789 }

      it "maintains precision" do
        expect(serialize).to eq(123.456789123456789)
      end
    end
  end
end
