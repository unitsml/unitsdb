require_relative "key_value_mapping_rule"

module Lutaml
  module Model
    class KeyValueMapping
      attr_reader :mappings

      def initialize
        @mappings = []
      end

      def map(
        name = nil,
        to: nil,
        render_nil: false,
        render_default: false,
        with: {},
        delegate: nil,
        child_mappings: nil,
        root_mappings: nil
      )
        mapping_name = name_for_mapping(root_mappings, name)
        validate!(mapping_name, to, with)

        @mappings << KeyValueMappingRule.new(
          mapping_name,
          to: to,
          render_nil: render_nil,
          render_default: render_default,
          with: with,
          delegate: delegate,
          child_mappings: child_mappings,
          root_mappings: root_mappings,
        )
      end

      alias map_element map

      def name_for_mapping(root_mappings, name)
        return "root_mapping" if root_mappings

        name
      end

      def validate!(key, to, with)
        if to.nil? && with.empty?
          msg = ":to or :with argument is required for mapping '#{key}'"
          raise IncorrectMappingArgumentsError.new(msg)
        end

        if !with.empty? && (with[:from].nil? || with[:to].nil?)
          msg = ":with argument for mapping '#{key}' requires :to and :from keys"
          raise IncorrectMappingArgumentsError.new(msg)
        end

        validate_mappings(key)
      end

      def validate_mappings(name)
        if @mappings.any?(&:root_mapping?) || (name == "root_mapping" && @mappings.any?)
          raise MultipleMappingsError.new("root_mappings cannot be used with other mappings")
        end
      end

      def deep_dup
        self.class.new.tap do |new_mapping|
          new_mapping.instance_variable_set(:@mappings, duplicate_mappings)
        end
      end

      def duplicate_mappings
        @mappings.map(&:deep_dup)
      end

      def find_by_to(to)
        @mappings.find { |m| m.to.to_s == to.to_s }
      end
    end
  end
end
