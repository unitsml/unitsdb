module Lutaml
  module Model
    module Config
      extend self

      # Default values are set for these so the readers are defined below
      attr_writer :json_adapter, :yaml_adapter

      attr_accessor :xml_adapter, :toml_adapter

      AVAILABLE_FORMATS = %i[xml json yaml toml].freeze
      KEY_VALUE_FORMATS = AVAILABLE_FORMATS - %i[xml]

      def configure
        yield self
      end

      # This will generate the following methods
      #
      # xml_adapter_type=
      #   @params:
      #     one of [:nokogiri, :ox, :oga]
      #   @example
      #     Lutaml::Model::Config.xml_adapter = :nokogiri
      #
      # json_adapter_type=
      #   @params:
      #     one of [:standard_json, :multi_json]
      #     if not set, :standard_json will be used by default
      #   @example
      #     Lutaml::Model::Config.json_adapter = :standard_json
      #
      # yaml_adapter_type=
      #   @params:
      #     one of [:standard_yaml]
      #     if not set, :standard_yaml will be used by default
      #   @example
      #     Lutaml::Model::Config.yaml_adapter = :standard_yaml
      #
      # toml_adapter_type=
      #   @params
      #     one of [:tomlib, :toml_rb]
      #   @example
      #     Lutaml::Model::Config.toml_adapter = :tomlib
      AVAILABLE_FORMATS.each do |adapter_name|
        define_method(:"#{adapter_name}_adapter_type=") do |type_name|
          adapter = "#{adapter_name}_adapter"
          type = "#{type_name}_adapter"

          begin
            adapter_file = File.join(adapter, type)
            require_relative adapter_file
          rescue LoadError
            raise(
              Lutaml::Model::UnknownAdapterTypeError.new(
                adapter_name,
                type_name,
              ),
              cause: nil,
            )
          end

          instance_variable_set(
            :"@#{adapter}",
            Lutaml::Model.const_get(to_class_name(adapter))
                         .const_get(to_class_name(type)),
          )
        end
      end

      # Return JSON adapter. By default StandardJsonAdapter is used
      #
      # @example
      #   Lutaml::Model::Config.json_adapter
      #   # => Lutaml::Model::YamlAdapter::StandardJsonAdapter
      def json_adapter
        @json_adapter || Lutaml::Model::JsonAdapter::StandardJsonAdapter
      end

      # Return YAML adapter. By default StandardYamlAdapter is used
      #
      # @example
      #   Lutaml::Model::Config.yaml_adapter
      #   # => Lutaml::Model::YamlAdapter::StandardYamlAdapter
      def yaml_adapter
        @yaml_adapter || Lutaml::Model::YamlAdapter::StandardYamlAdapter
      end

      # @api private
      def to_class_name(str)
        str.to_s.split("_").map(&:capitalize).join
      end
    end
  end
end
