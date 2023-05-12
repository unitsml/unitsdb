require 'ox'
require 'rspec'
require 'yaml'

describe 'MathML in UnitsDB' do
  unitsdb = YAML.load_file('units.yaml')

  unitsdb.each do |unit, unit_data|
    context "when parsing MathML for #{unit}" do
      it 'parses successfully' do
        mathml_values = [unit_data['mathml']].flatten.compact
        mathml_values.each do |mathml|
          expect { Ox.parse(mathml) }.not_to raise_error
        end
      end
    end
  end
end
