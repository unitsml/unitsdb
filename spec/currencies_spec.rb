# frozen_string_literal: true

require "yaml"

describe "currencies.yaml" do
  currencies = YAML.load_file(File.join(__dir__, "../currencies.yaml"))["currencies"]

  it "is a non-empty collection" do
    expect(currencies).not_to be_empty
  end

  it "carries unique ISO 4217 codes" do
    codes = currencies.filter_map { |c| c["identifiers"].find { |i| i["type"] == "iso4217" }&.dig("id") }
    expect(codes.uniq.size).to eq(codes.size)
    expect(codes).to all(match(/\A[A-Z]{3}\z/))
  end

  it "carries unique cur:-prefixed unitsml ids" do
    ids = currencies.filter_map { |c| c["identifiers"].find { |i| i["type"] == "unitsml" }&.dig("id") }
    expect(ids.uniq.size).to eq(ids.size)
    expect(ids).to all(start_with("cur:"))
  end

  it "keeps the unitsml id in lockstep with the ISO code" do
    currencies.each do |c|
      code = c["identifiers"].find { |i| i["type"] == "iso4217" }["id"]
      uid = c["identifiers"].find { |i| i["type"] == "unitsml" }["id"]
      expect(uid).to eq("cur:#{code}")
    end
  end

  it "carries unique ISO numeric codes in lockstep with the alpha codes" do
    currencies.each do |c|
      alpha = c["identifiers"].find { |i| i["type"] == "iso4217" }["id"]
      numeric = c["identifiers"].find { |i| i["type"] == "iso4217_numeric" }["id"]
      expect(numeric).to match(/\A\d{3}\z/)
      expect(alpha).to be_a(String)
    end
    numerics = currencies.filter_map { |c| c["identifiers"].find { |i| i["type"] == "iso4217_numeric" }&.dig("id") }
    expect(numerics.uniq.size).to eq(numerics.size)
  end

  it "declares minor-unit exponents within ISO 4217 range" do
    expect(currencies.map { |c| c["minor_unit_exponent"] }).to all(be_between(0, 4))
  end

  it "declares every currency with the monetary-value quantity and the iso-4217 system" do
    currencies.each do |c|
      expect(c["quantity_references"]).to include({ "type" => "unitsml", "id" => "q:monetary_value" })
      expect(c["unit_system_reference"]).to include({ "type" => "unitsml", "id" => "us:iso-4217" })
    end
  end

  it "never carries root units or cross-currency factors" do
    currencies.each do |c|
      expect(c).not_to have_key("root_units")
      expect(c).not_to have_key("scale_reference")
    end
  end
end
