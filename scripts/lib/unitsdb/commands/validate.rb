require 'thor'
require_relative 'validate/references'
require_relative 'validate/uniqueness'

module Unitsdb
  module Commands
    class ValidateCommand < Thor
      desc "references [INPUT]", "Validate that all references exist"
      subcommand "references", Validate::References

      desc "uniqueness [INPUT]", "Check for uniqueness of 'short' and 'id' fields"
      subcommand "uniqueness", Validate::Uniqueness
    end
  end
end
