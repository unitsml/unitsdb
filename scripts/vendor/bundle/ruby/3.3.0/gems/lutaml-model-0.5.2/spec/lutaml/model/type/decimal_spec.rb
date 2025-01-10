require "spec_helper"
require "bigdecimal"

RSpec.describe Lutaml::Model::Type do
  describe "Decimal type" do
    let(:decimal_class) { Lutaml::Model::Type::Decimal }

    context "when bigdecimal is loaded" do
      before do
        # Ensure BigDecimal is loaded
        require "bigdecimal"
      end

      it "serializes into Lutaml::Model::Type::Decimal" do
        value = BigDecimal("123.45")
        serialized = decimal_class.serialize(value)
        expect(serialized).to eq("123.45")
      end

      it "deserializes into Ruby BigDecimal" do
        value = "123.45"
        deserialized = decimal_class.cast(value)
        expect(deserialized).to be_a(BigDecimal)
        expect(deserialized).to eq(BigDecimal("123.45"))
      end
    end

    context "when bigdecimal is not loaded" do
      before do
        hide_const("BigDecimal")
      end

      it "raises TypeNotEnabledError when serializing" do
        expect do
          decimal_class.serialize(123.45)
        end.to raise_error(Lutaml::Model::TypeNotEnabledError, /Decimal/)
      end

      it "raises TypeNotEnabledError when deserializing" do
        expect do
          decimal_class.cast("123.45")
        end.to raise_error(Lutaml::Model::TypeNotEnabledError, /Decimal/)
      end
    end
  end

  describe ".cast" do
    context "with BigDecimal available" do
      before do
        # Ensure BigDecimal is loaded
        require "bigdecimal"
      end

      let(:decimal_class) { Lutaml::Model::Type::Decimal }

      it "returns nil for nil input" do
        expect(decimal_class.cast(nil)).to be_nil
      end

      it "casts numeric string to BigDecimal" do
        expect(decimal_class.cast("123.45")).to eq BigDecimal("123.45")
      end

      it "casts integer to BigDecimal" do
        expect(decimal_class.cast(123)).to eq BigDecimal("123")
      end

      it "casts float to BigDecimal" do
        expect(decimal_class.cast(123.45)).to eq BigDecimal("123.45")
      end

      it "casts BigDecimal to BigDecimal" do
        value = BigDecimal("123.45")
        expect(decimal_class.cast(value)).to eq value
      end
    end

    context "with BigDecimal not available", :skip_before do
      before do
        hide_const("BigDecimal")
      end

      it "raises TypeNotEnabledError" do
        expect { Lutaml::Model::Type::Decimal.cast("123.45") }.to raise_error(
          Lutaml::Model::TypeNotEnabledError,
          /Decimal/,
        )
      end
    end
  end

  describe ".serialize" do
    context "with BigDecimal available" do
      let(:decimal_class) { Lutaml::Model::Type::Decimal }

      before do
        # Ensure BigDecimal is loaded
        require "bigdecimal"
      end

      it "returns nil for nil input" do
        expect(decimal_class.serialize(nil)).to be_nil
      end

      it "serializes BigDecimal to string" do
        expect(decimal_class.serialize(BigDecimal("123.45"))).to eq "123.45"
      end
    end

    context "with BigDecimal not available", :skip_before do
      before do
        hide_const("BigDecimal")
      end

      it "raises TypeNotEnabledError" do
        expect do
          Lutaml::Model::Type::Decimal.serialize("123.45")
        end.to raise_error(
          Lutaml::Model::TypeNotEnabledError,
          /Decimal/,
        )
      end
    end
  end
end
