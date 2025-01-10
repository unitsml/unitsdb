require "spec_helper"

RSpec.describe Lutaml::Model::Type::Date do
  describe ".cast" do
    subject(:cast) { described_class.cast(value) }

    context "with nil value" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "with valid Date string" do
      let(:value) { "2024-01-01" }

      it { is_expected.to eq(Date.new(2024, 1, 1)) }
    end

    context "with Date object" do
      let(:value) { Date.new(2024, 1, 1) }

      it { is_expected.to eq(value) }
    end

    context "with DateTime object" do
      let(:value) { DateTime.new(2024, 1, 1, 12, 0, 0) }

      it { is_expected.to eq(Date.new(2024, 1, 1)) }
    end

    context "with Time object" do
      let(:value) { Time.new(2024, 1, 1, 12, 0, 0) }

      it { is_expected.to eq(Date.new(2024, 1, 1)) }
    end

    context "with invalid date string" do
      let(:value) { "not a date" }

      it { is_expected.to be_nil }
    end

    context "with invalid month" do
      let(:value) { "2024-13-01" }

      it { is_expected.to be_nil }
    end

    context "with invalid day" do
      let(:value) { "2024-04-31" }

      it { is_expected.to be_nil }
    end

    context "with different date formats" do
      it "parses ISO 8601" do
        expect(described_class.cast("2024-01-01")).to eq(Date.new(2024, 1, 1))
      end

      it "parses RFC 3339" do
        expect(described_class.cast("2024-01-01T12:00:00Z")).to eq(Date.new(
                                                                     2024, 1, 1
                                                                   ))
      end

      it "parses common formats" do
        expect(described_class.cast("01/01/2024")).to eq(Date.new(2024, 1, 1))
        expect(described_class.cast("Jan 1, 2024")).to eq(Date.new(2024, 1, 1))
      end
    end

    context "with leap year dates" do
      it "handles February 29 in leap years" do
        expect(described_class.cast("2024-02-29")).to eq(Date.new(2024, 2, 29))
      end

      it "rejects February 29 in non-leap years" do
        expect(described_class.cast("2023-02-29")).to be_nil
      end
    end
  end

  describe ".serialize" do
    subject(:serialize) { described_class.serialize(value) }

    context "with nil value" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "with Date object" do
      let(:value) { Date.new(2024, 1, 1) }

      it { is_expected.to eq("2024-01-01") }
    end

    context "with single-digit month and day" do
      let(:value) { Date.new(2024, 1, 1) }

      it "zero-pads month and day" do
        expect(serialize).to eq("2024-01-01")
      end
    end

    context "with double-digit month and day" do
      let(:value) { Date.new(2024, 12, 31) }

      it { is_expected.to eq("2024-12-31") }
    end

    context "with leap year date" do
      let(:value) { Date.new(2024, 2, 29) }

      it { is_expected.to eq("2024-02-29") }
    end
  end
end
