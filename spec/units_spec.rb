# frozen_string_literal: true

require "yaml"
require "rspec"
require "plurimath/math"

describe "Validate MathML in UnitsDB" do
  unitsdb = YAML.load_file(File.join(__dir__, "../units.yaml"))

  unitsdb.each do |unit, unit_data|
    context "when parsing MathML for #{unit}" do
      it "parses successfully" do
        symbols = unit_data["symbols"].flatten.compact
        symbols.each do |symbols_hash|
          expect { Plurimath::Math.parse(symbols_hash["mathml"], :mathml) }.not_to raise_error
        end
      end
    end
  end
end
