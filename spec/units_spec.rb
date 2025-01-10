require "yaml"
require "rspec"
require "plurimath/math"

describe "Validate MathML in UnitsDB" do
  unitsdb = YAML.load_file(File.join(__dir__, "../units.yaml"))

  unitsdb.each do |unit, unit_data|
    context "when parsing MathML for #{unit}" do
      it "parses successfully" do
        unit_symbols = unit_data.dig("unit_symbols").flatten.compact
        unit_symbols.each do |symbols_hash|
          expect { Plurimath::Math.parse(symbols_hash.dig("mathml"), :mathml) }.not_to raise_error
        end
      end
    end
  end
end
