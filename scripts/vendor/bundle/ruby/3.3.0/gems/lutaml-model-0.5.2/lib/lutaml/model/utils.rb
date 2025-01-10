# frozen_string_literal: true

module Lutaml
  module Model
    module Utils
      class << self
        # Convert string to camel case
        def camel_case(str)
          return "" if str.nil? || str.empty?

          str.split("/").map { |part| camelize_part(part) }.join("::")
        end

        # Convert string to class name
        def classify(str)
          str = str.to_s.delete(".")
          str = str.sub(/^[a-z\d]*/) { |match| camel_case(match) || match }

          str.gsub("::", "/").gsub(%r{(?:_|-|(/))([a-z\d]*)}i) do
            word = Regexp.last_match(2)
            substituted = camel_case(word) || word
            Regexp.last_match(1) ? "::#{substituted}" : substituted
          end
        end

        # Convert string to snake case
        def snake_case(str)
          str = str.to_s.tr(".", "_")
          return str unless /[A-Z-]|::/.match?(str)

          str.gsub("::", "/")
            .gsub(/([A-Z]+)(?=[A-Z][a-z])|([a-z\d])(?=[A-Z])/) { "#{$1 || $2}_" }
            .tr("-", "_")
            .downcase
        end

        def present?(value)
          !blank?(value)
        end

        def blank?(value)
          value.respond_to?(:empty?) ? value.empty? : value.nil?
        end

        def add_method_if_not_defined(klass, method_name, &block)
          unless klass.method_defined?(method_name)
            klass.class_eval do
              define_method(method_name, &block)
            end
          end
        end

        def add_accessor_if_not_defined(klass, attribute)
          add_getter_if_not_defined(klass, attribute)
          add_setter_if_not_defined(klass, attribute)
        end

        def add_boolean_accessor_if_not_defined(klass, attribute)
          add_boolean_getter_if_not_defined(klass, attribute)
          add_setter_if_not_defined(klass, attribute)
        end

        def add_getter_if_not_defined(klass, attribute)
          add_method_if_not_defined(klass, attribute) do
            instance_variable_get(:"@__#{attribute}")
          end
        end

        def add_boolean_getter_if_not_defined(klass, attribute)
          add_method_if_not_defined(klass, "#{attribute}?") do
            !!instance_variable_get(:"@__#{attribute}")
          end
        end

        def add_setter_if_not_defined(klass, attribute)
          add_method_if_not_defined(klass, "#{attribute}=") do |value|
            instance_variable_set(:"@__#{attribute}", value)
          end
        end

        def deep_dup(hash)
          return hash if hash.nil?

          new_hash = {}

          hash.each do |key, value|
            new_hash[key] = if value.is_a?(Hash)
                              deep_dup(value)
                            elsif value.respond_to?(:deep_dup)
                              value.deep_dup
                            else
                              value.dup
                            end
          end

          new_hash
        end

        private

        def camelize_part(part)
          part.gsub(/(?:_|-|^)([a-z\d])/i) { $1.upcase }
        end
      end
    end
  end
end
