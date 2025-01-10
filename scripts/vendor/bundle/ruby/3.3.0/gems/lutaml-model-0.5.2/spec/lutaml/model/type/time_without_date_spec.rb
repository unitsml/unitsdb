require "spec_helper"

RSpec.describe Lutaml::Model::Type::TimeWithoutDate do
  describe ".cast" do
    subject(:cast) { described_class.cast(value) }

    context "with nil value" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "with time string" do
      let(:value) { "13:45:30" }

      it "parses time correctly" do
        expect(cast.hour).to eq(13)
        expect(cast.min).to eq(45)
        expect(cast.sec).to eq(30)
      end
    end

    context "with time string with milliseconds" do
      let(:value) { "13:45:30.500" }

      it "parses time with milliseconds" do
        expect(cast.hour).to eq(13)
        expect(cast.min).to eq(45)
        expect(cast.sec).to eq(30)
        expect(cast.nsec).to eq(500_000_000)
      end
    end

    context "with Time object" do
      let(:value) { Time.new(2024, 1, 1, 13, 45, 30) }

      it "extracts time components" do
        expect(cast.hour).to eq(13)
        expect(cast.min).to eq(45)
        expect(cast.sec).to eq(30)
      end
    end

    context "with DateTime object" do
      let(:value) { DateTime.new(2024, 1, 1, 13, 45, 30) }

      it "extracts time components" do
        expect(cast.hour).to eq(13)
        expect(cast.min).to eq(45)
        expect(cast.sec).to eq(30)
      end
    end

    context "with invalid time string" do
      let(:value) { "not a time" }

      it { is_expected.to be_nil }
    end

    context "with invalid hours" do
      let(:value) { "24:00:00" }

      xit { is_expected.to be_nil }
    end

    context "with invalid minutes" do
      let(:value) { "12:60:00" }

      it { is_expected.to be_nil }
    end

    context "with invalid seconds" do
      let(:value) { "12:00:61" }

      it { is_expected.to be_nil }
    end

    context "with microsecond precision" do
      let(:value) { "13:45:30.123456" }

      it "retains microsecond precision" do
        expect(cast.hour).to eq(13)
        expect(cast.min).to eq(45)
        expect(cast.sec).to eq(30)
        expect(cast.usec).to eq(123456)
      end
    end
  end

  describe ".serialize" do
    subject(:serialize) { described_class.serialize(value) }

    context "with nil value" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "with Time object" do
      let(:value) { Time.new(2024, 1, 1, 13, 45, 30) }

      it { is_expected.to eq("13:45:30") }
    end

    context "with single-digit values" do
      let(:value) { Time.new(2024, 1, 1, 9, 5, 3) }

      it "zero-pads values" do
        expect(serialize).to eq("09:05:03")
      end
    end

    context "with double-digit values" do
      let(:value) { Time.new(2024, 1, 1, 13, 45, 30) }

      it { is_expected.to eq("13:45:30") }
    end

    context "with zero values" do
      let(:value) { Time.new(2024, 1, 1, 0, 0, 0) }

      it { is_expected.to eq("00:00:00") }
    end
  end
end
