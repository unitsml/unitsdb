#!/usr/bin/env ruby

require 'yaml'
require 'json-schema'
require 'json'
require 'pathname'

class SchemaValidator
  def initialize
    @schemas_dir = Pathname.new('schemas')
    @errors_found = false
  end

  def validate_all
    puts "UnitsDB Schema Validation"
    puts "=" * 50

    # Define the mapping of YAML files to their schemas
    file_schema_map = {
      'units.yaml' => 'units-schema.yaml',
      'quantities.yaml' => 'quantities-schema.yaml',
      'scales.yaml' => 'scales-schema.yaml',
      'prefixes.yaml' => 'prefixes-schema.yaml',
      'unit_systems.yaml' => 'unit_systems-schema.yaml',
      'dimensions.yaml' => 'dimensions-schema.yaml'
    }

    file_schema_map.each do |yaml_file, schema_file|
      validate_file(yaml_file, schema_file)
    end

    puts "\n" + "=" * 50
    if @errors_found
      puts "❌ Validation completed with errors"
      exit 1
    else
      puts "✅ All files passed validation"
      exit 0
    end
  end

  private

  def validate_file(yaml_file, schema_file)
    puts "\nValidating #{yaml_file}..."

    # Check if files exist
    unless File.exist?(yaml_file)
      puts "❌ YAML file not found: #{yaml_file}"
      @errors_found = true
      return
    end

    schema_path = @schemas_dir / schema_file
    unless File.exist?(schema_path)
      puts "❌ Schema file not found: #{schema_path}"
      @errors_found = true
      return
    end

    begin
      # Load YAML data
      yaml_data = YAML.load_file(yaml_file)

      # Load schema (YAML schemas need to be converted to JSON for json-schema gem)
      schema_yaml = YAML.load_file(schema_path)
      schema_json = JSON.parse(schema_yaml.to_json)

      # Validate
      errors = JSON::Validator.fully_validate(schema_json, yaml_data,
                                             errors_as_objects: true,
                                             validate_schema: true)

      if errors.empty?
        puts "✅ #{yaml_file} - Valid"
      else
        puts "❌ #{yaml_file} - #{errors.length} error(s) found:"
        @errors_found = true

        errors.each_with_index do |error, index|
          puts "\n  Error #{index + 1}:"
          puts "    Path: #{error[:fragment] || 'root'}"
          puts "    Message: #{error[:message]}"

          # Try to provide more context about the location
          if error[:fragment] && !error[:fragment].empty?
            path_parts = error[:fragment].split('/')
            puts "    Location: #{describe_path(path_parts, yaml_data)}"
          end

          # Show the failing value if available
          if error[:failed_attribute] && error[:failed_attribute] != 'schema'
            puts "    Failed validation: #{error[:failed_attribute]}"
          end
        end
      end

    rescue YAML::SyntaxError => e
      puts "❌ YAML syntax error in #{yaml_file}:"
      puts "    Line #{e.line}: #{e.problem}"
      @errors_found = true
    rescue JSON::Schema::ValidationError => e
      puts "❌ Schema validation error: #{e.message}"
      @errors_found = true
    rescue StandardError => e
      puts "❌ Unexpected error validating #{yaml_file}: #{e.message}"
      puts "    #{e.class}: #{e.backtrace.first}"
      @errors_found = true
    end
  end

  def describe_path(path_parts, data)
    current = data
    description_parts = []

    path_parts.each do |part|
      next if part.empty? || part == '#'

      if part =~ /^\d+$/
        # Array index
        index = part.to_i
        if current.is_a?(Array) && current[index]
          description_parts << "item #{index}"
          current = current[index]
        else
          description_parts << "index #{index} (out of bounds)"
          break
        end
      else
        # Object property
        if current.is_a?(Hash) && current.key?(part)
          description_parts << "property '#{part}'"
          current = current[part]
        else
          description_parts << "missing property '#{part}'"
          break
        end
      end
    end

    description_parts.join(' -> ')
  end
end

# Additional helper methods for detailed error reporting
class SchemaValidator
  def self.check_dependencies
    begin
      require 'json-schema'
    rescue LoadError
      puts "❌ Missing required gem: json-schema"
      puts "   Install with: gem install json-schema"
      exit 1
    end
  end

  def self.run_with_options
    check_dependencies

    if ARGV.include?('--help') || ARGV.include?('-h')
      show_help
      exit 0
    end

    validator = new

    if ARGV.include?('--verbose') || ARGV.include?('-v')
      puts "Ruby version: #{RUBY_VERSION}"
      puts "JSON Schema gem version: #{JSON::Schema::VERSION}"
      puts "Working directory: #{Dir.pwd}"
      puts ""
    end

    validator.validate_all
  end

  def self.show_help
    puts <<~HELP
      UnitsDB Schema Validator

      Usage: ruby validate_schemas.rb [options]

      Options:
        -h, --help     Show this help message
        -v, --verbose  Show additional information

      This script validates all YAML files in the UnitsDB repository
      against their corresponding JSON schemas in the schemas/ directory.

      Files validated:
        - units.yaml
        - quantities.yaml
        - scales.yaml
        - prefixes.yaml
        - unit_systems.yaml
        - dimensions.yaml

      Exit codes:
        0 - All files passed validation
        1 - Validation errors found or script error
    HELP
  end
end

# Run the validator if this script is executed directly
if __FILE__ == $0
  SchemaValidator.run_with_options
end
