require_relative '../base'

module Unitsdb
  module Commands
    module Validate
      class Base < Unitsdb::Commands::Base
        class_option :print_valid, type: :boolean, default: false, desc: "Also print valid references"
      end
    end
  end
end
