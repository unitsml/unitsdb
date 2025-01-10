module Lutaml
  module Model
    class Error < StandardError
    end
  end
end

require_relative "error/invalid_value_error"
require_relative "error/incorrect_mapping_argument_error"
require_relative "error/pattern_not_matched_error"
require_relative "error/unknown_adapter_type_error"
require_relative "error/collection_count_out_of_range_error"
require_relative "error/validation_error"
require_relative "error/type_not_enabled_error"
require_relative "error/type_error"
require_relative "error/unknown_type_error"
require_relative "error/multiple_mappings_error"
require_relative "error/collection_true_missing_error"
