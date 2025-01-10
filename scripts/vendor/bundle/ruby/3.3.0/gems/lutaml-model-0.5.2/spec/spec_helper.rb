# frozen_string_literal: true

require "rspec/matchers"
require "equivalent-xml"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def fixture_path(filename)
    File.expand_path("../fixtures/#{filename}", __FILE__)
  end
end

# configuration example
require_relative "../lib/lutaml/model"
require_relative "../lib/lutaml/model/xml_adapter/nokogiri_adapter"
require_relative "../lib/lutaml/model/xml_adapter/ox_adapter"
require_relative "../lib/lutaml/model/toml_adapter/toml_rb_adapter"

Lutaml::Model::Config.configure do |config|
  config.xml_adapter_type = :nokogiri
  config.json_adapter_type = :standard_json
  config.yaml_adapter_type = :standard_yaml
  config.toml_adapter_type = :toml_rb
end
