require_relative "schema/json_schema"
require_relative "schema/xsd_schema"
require_relative "schema/relaxng_schema"
require_relative "schema/yaml_schema"

module Lutaml
  module Model
    module Schema
      def self.to_json(klass, options = {})
        JsonSchema.generate(klass, options)
      end

      def self.to_xsd(klass, options = {})
        XsdSchema.generate(klass, options)
      end

      def self.to_relaxng(klass, options = {})
        RelaxngSchema.generate(klass, options)
      end

      def self.to_yaml(klass, options = {})
        YamlSchema.generate(klass, options)
      end
    end
  end
end
