# frozen_string_literal: true

require "yaml"
module Unitsml
  module Unitsdb
    class << self
      def load_yaml(file_name)
        @@hash ||= {}
        @@hash[file_name] ||= YAML.load_file(valid_path(file_name))
      end

      def load_dimensions
        @@dim_file = load_yaml(:dimensions)
      end

      def load_units
        @@units_file = load_yaml(:units)
      end

      def units
        @@units ||= {}
        return @@units unless @@units.empty?

        load_units.each do |key, value|
          value["unit_symbols"]&.each do |symbol|
            @@units[symbol["id"]] = { id: key, fields: value } unless symbol["id"]&.empty?
          end
        end
        @@units
      end

      def prefixes
        @@prefixes_array ||= prefixes_hash.keys.sort_by(&:length)
      end

      def parsable_dimensions
        @@parsable_dimensions ||= {}
        return @@parsable_dimensions unless @@parsable_dimensions.empty?

        dimensions_hash.each do |key, value|
          value.each do |_, v|
            @@parsable_dimensions[find_id(v)] = { id: key, fields: value }
          end
        end
        @@parsable_dimensions
      end

      def quantities
        @@quantities ||= load_yaml(:quantities)
      end

      def filtered_units
        @@filtered_units_array ||= units.keys.reject do |unit|
          ((/\*|\^|\/|^1$/).match?(unit) || units.dig(unit, :fields, "prefixed"))
        end
      end

      def prefixes_hash
        @@prefixes_hashes ||= prefixs_ids(load_yaml(:prefixes))
      end

      def dimensions_hash
        @@dimensions_hashs ||= insert_vectors(load_dimensions)
      end

      def prefixs_ids(prefixe_hash, hash = {})
        prefixe_hash&.each do |key, value|
          symbol = value&.dig("symbol", "ascii")
          hash[symbol] = { id: key, fields: value } unless symbol&.empty?
        end
        hash
      end

      def find_id(value)
        return if value == true
        return unless value.is_a?(Hash)

        value&.dig("dim_symbols")&.map { |symbol| symbol&.dig("id") }&.first
      end

      def vector(dim_hash)
        Utility::DIMS_VECTOR.map { |h| dim_hash.dig(underscore(h), "powerNumerator") }.join(":")
      end

      def underscore(str)
        str.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
      end

      def insert_vectors(dims)
        dims.each do |key, value|
          value[:vector] = vector(value)
          value[:id] = key
        end
      end

      def valid_path(file_name)
        File.expand_path(
          File.join(__dir__, "..", "..","unitsdb", "#{file_name}.yaml")
        )
      end
    end
  end
end
