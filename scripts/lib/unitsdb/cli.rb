require 'thor'
require_relative 'commands/uniqueness'
require_relative 'commands/normalize'
require_relative 'commands/validate'

module Unitsdb
  class CLI < Thor
    desc "check_uniqueness [INPUT]", "Check for uniqueness of 'short' and 'id' fields in a YAML file"
    method_option :all, type: :boolean, default: false, aliases: "-a", desc: "Check all YAML files in the repository"
    method_option :dir, type: :string, default: ".", aliases: "-d", desc: "Directory containing the YAML files"

    def check_uniqueness(input=nil)
      Commands::Uniqueness.new.check(input)
    end

    desc "normalize [INPUT] [OUTPUT]", "Normalize a YAML file or all YAML files with --all"
    method_option :sort, type: :boolean, default: true, desc: "Sort keys alphabetically"
    method_option :all, type: :boolean, default: false, aliases: "-a", desc: "Normalize all YAML files in the repository"
    method_option :dir, type: :string, default: ".", aliases: "-d", desc: "Directory containing the YAML files"

    def normalize(input=nil, output=nil)
      Commands::Normalize.new.yaml(input, output)
    end

    desc "validate SUBCOMMAND", "Validate YAML files for different conditions"
    subcommand "validate", Commands::ValidateCommand
  end
end
