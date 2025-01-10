require "spec_helper"

RSpec.describe Lutaml::Model::Type::DateTime do
  describe ".cast" do
    subject(:cast) { described_class.cast(value) }

    context "with nil value" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "with valid DateTime string" do
      let(:value) { "2024-01-01T12:00:00Z" }

      it "parses with UTC offset" do
        expect(cast.offset).to eq(0)
        expect(cast.zone).to eq("+00:00")
      end
    end

    context "with positive timezone offset" do
      let(:value) { "2024-01-01T12:00:00+08:00" }

      it "retains the positive offset" do
        expect(cast.offset).to eq(Rational(8, 24))
        expect(cast.zone).to eq("+08:00")
      end
    end

    context "with negative timezone offset" do
      let(:value) { "2024-01-01T12:00:00-05:00" }

      it "retains the negative offset" do
        expect(cast.offset).to eq(Rational(-5, 24))
        expect(cast.zone).to eq("-05:00")
      end
    end

    context "with fractional offset" do
      let(:value) { "2024-01-01T12:00:00+05:30" }

      it "retains the fractional offset" do
        expect(cast.offset).to eq(Rational(5.5, 24))
        expect(cast.zone).to eq("+05:30")
      end
    end

    context "with Time object with offset" do
      let(:value) { Time.new(2024, 1, 1, 12, 0, 0, "+08:00") }

      it "preserves the offset from Time object" do
        expect(cast.offset).to eq(Rational(8, 24))
        expect(cast.zone).to eq("+08:00")
      end
    end

    context "with DateTime object with offset" do
      let(:value) { DateTime.new(2024, 1, 1, 12, 0, 0, "+08:00") }

      it "preserves the offset from DateTime object" do
        expect(cast.offset).to eq(Rational(8, 24))
        expect(cast.zone).to eq("+08:00")
      end
    end
  end

  describe ".serialize" do
    subject(:serialize) { described_class.serialize(value) }

    context "with nil value" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "with UTC DateTime" do
      let(:value) { DateTime.new(2024, 1, 1, 12, 0, 0) }

      it "serializes with +00:00 offset" do
        expect(serialize).to eq("2024-01-01T12:00:00+00:00")
      end
    end

    context "with positive offset" do
      let(:value) { DateTime.new(2024, 1, 1, 12, 0, 0, "+08:00") }

      it "retains positive offset in serialized form" do
        expect(serialize).to eq("2024-01-01T12:00:00+08:00")
      end
    end

    context "with negative offset" do
      let(:value) { DateTime.new(2024, 1, 1, 12, 0, 0, "-05:00") }

      it "retains negative offset in serialized form" do
        expect(serialize).to eq("2024-01-01T12:00:00-05:00")
      end
    end

    context "with fractional offset" do
      let(:value) { DateTime.new(2024, 1, 1, 12, 0, 0, "+05:30") }

      it "retains fractional offset in serialized form" do
        expect(serialize).to eq("2024-01-01T12:00:00+05:30")
      end
    end

    context "with fractional seconds" do
      let(:value) { DateTime.new(2024, 1, 1, 12, 0, 0.5, "+08:00") }

      xit "retains both fractional seconds and offset" do
        expect(serialize).to eq("2024-01-01T12:00:00.500+08:00")
      end
    end

    context "with microsecond precision" do
      let(:value) do
        DateTime.new(2024, 1, 1, 12, 0, Rational(123456, 1000000), "+08:00")
      end

      xit "retains microsecond precision and offset" do
        expect(serialize).to eq("2024-01-01T12:00:00.123456+08:00")
      end
    end
  end
end
