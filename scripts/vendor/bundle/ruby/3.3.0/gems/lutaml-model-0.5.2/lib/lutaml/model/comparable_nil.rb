# frozen_string_literal: true

require_relative "serializable"

module Lutaml
  module Model
    # Nil class substitute for comparison
    class ComparableNil < ::Lutaml::Model::Serializable
    end
  end
end
