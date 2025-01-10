require "spec_helper"

RSpec.describe Lutaml::Model::Type::Time do
  describe ".cast" do
    subject(:cast) { described_class.cast(value) }

    context "with nil value" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "with valid Time string" do
      let(:value) { "2024-01-01T12:00:00Z" }

      it "parses with UTC offset" do
        expect(cast.utc_offset).to eq(0)
        expect(cast.strftime("%:z")).to eq("+00:00")
      end
    end

    context "with positive timezone offset" do
      let(:value) { "2024-01-01T12:00:00+08:00" }

      it "retains the positive offset" do
        expect(cast.utc_offset).to eq(8 * 3600)
        expect(cast.strftime("%:z")).to eq("+08:00")
      end
    end

    context "with negative timezone offset" do
      let(:value) { "2024-01-01T12:00:00-05:00" }

      it "retains the negative offset" do
        expect(cast.utc_offset).to eq(-5 * 3600)
        expect(cast.strftime("%:z")).to eq("-05:00")
      end
    end

    context "with fractional offset" do
      let(:value) { "2024-01-01T12:00:00+05:30" }

      it "retains the fractional offset" do
        expect(cast.utc_offset).to eq((5 * 3600) + (30 * 60))
        expect(cast.strftime("%:z")).to eq("+05:30")
      end
    end

    context "with DateTime object" do
      let(:value) { DateTime.new(2024, 1, 1, 12, 0, 0, "+08:00") }

      it "preserves the offset" do
        expect(cast.utc_offset).to eq(8 * 3600)
        expect(cast.strftime("%:z")).to eq("+08:00")
      end
    end

    context "with Time object" do
      let(:value) { Time.new(2024, 1, 1, 12, 0, 0, "+08:00") }

      it "preserves the offset" do
        expect(cast.utc_offset).to eq(8 * 3600)
        expect(cast.strftime("%:z")).to eq("+08:00")
      end
    end

    context "with invalid Time string" do
      let(:value) { "not a time" }

      it { is_expected.to be_nil }
    end

    context "with microsecond precision" do
      let(:value) { "2024-01-01T12:00:00.123456+08:00" }

      it "retains microsecond precision" do
        expect(cast.usec).to eq(123456)
        expect(cast.strftime("%:z")).to eq("+08:00")
      end
    end
  end

  describe ".serialize" do
    subject(:serialize) { described_class.serialize(value) }

    context "with nil value" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "with UTC Time" do
      let(:value) { Time.new(2024, 1, 1, 12, 0, 0, "+00:00") }

      it "serializes with +00:00 offset" do
        expect(serialize).to eq("2024-01-01T12:00:00+00:00")
      end
    end

    context "with positive offset" do
      let(:value) { Time.new(2024, 1, 1, 12, 0, 0, "+08:00") }

      it "retains positive offset in serialized form" do
        expect(serialize).to eq("2024-01-01T12:00:00+08:00")
      end
    end

    context "with negative offset" do
      let(:value) { Time.new(2024, 1, 1, 12, 0, 0, "-05:00") }

      it "retains negative offset in serialized form" do
        expect(serialize).to eq("2024-01-01T12:00:00-05:00")
      end
    end

    context "with fractional offset" do
      let(:value) { Time.new(2024, 1, 1, 12, 0, 0, "+05:30") }

      it "retains fractional offset in serialized form" do
        expect(serialize).to eq("2024-01-01T12:00:00+05:30")
      end
    end

    context "with fractional seconds" do
      let(:value) { Time.new(2024, 1, 1, 12, 0, 0.5, "+08:00") }

      xit "retains both fractional seconds and offset" do
        expect(serialize).to eq("2024-01-01T12:00:00.500+08:00")
      end
    end

    context "with microsecond precision" do
      let(:value) { Time.at(Time.new(2024, 1, 1, 12).to_i, 123456, :usec) }

      before { value.localtime("+08:00") }

      xit "retains microsecond precision and offset" do
        expect(serialize).to eq("2024-01-01T12:00:00.123456+08:00")
      end
    end
  end
end
