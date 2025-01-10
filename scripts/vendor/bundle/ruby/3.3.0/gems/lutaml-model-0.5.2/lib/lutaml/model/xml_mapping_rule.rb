require_relative "mapping_rule"

module Lutaml
  module Model
    class XmlMappingRule < MappingRule
      attr_reader :namespace, :prefix, :mixed_content, :default_namespace, :cdata

      def initialize(
        name,
        to:,
        render_nil: false,
        render_default: false,
        with: {},
        delegate: nil,
        namespace: nil,
        prefix: nil,
        mixed_content: false,
        cdata: false,
        namespace_set: false,
        prefix_set: false,
        attribute: false,
        default_namespace: nil
      )
        super(
          name,
          to: to,
          render_nil: render_nil,
          render_default: render_default,
          with: with,
          delegate: delegate,
          attribute: attribute
        )

        @namespace = if namespace.to_s == "inherit"
                     # we are using inherit_namespace in xml builder by
                     # default so no need to do anything here.
                     else
                       namespace
                     end
        @prefix = prefix
        @mixed_content = mixed_content
        @cdata = cdata

        @default_namespace = default_namespace

        @namespace_set = namespace_set
        @prefix_set = prefix_set
      end

      def namespace_set?
        !!@namespace_set
      end

      def prefix_set?
        !!@prefix_set
      end

      def content_mapping?
        name.nil?
      end

      def raw_mapping?
        name == "__raw_mapping"
      end

      def content_key
        cdata ? "#cdata-section" : "text"
      end

      def mixed_content?
        !!@mixed_content
      end

      def prefixed_name
        rule_name = multiple_mappings? ? name.first : name
        if prefix
          "#{prefix}:#{rule_name}"
        else
          rule_name
        end
      end

      def namespaced_names(parent_namespace = nil)
        if multiple_mappings?
          name.map { |rule_name| namespaced_name(parent_namespace, rule_name) }
        else
          [namespaced_name(parent_namespace)]
        end
      end

      def namespaced_name(parent_namespace = nil, name = self.name)
        if name == "lang"
          "#{prefix}:#{name}"
        elsif namespace_set? || @attribute
          [namespace, name].compact.join(":")
        elsif default_namespace
          "#{default_namespace}:#{name}"
        else
          [parent_namespace, name].compact.join(":")
        end
      end

      def deep_dup
        self.class.new(
          name.dup,
          to: to,
          render_nil: render_nil,
          with: Utils.deep_dup(custom_methods),
          delegate: delegate,
          namespace: namespace.dup,
          prefix: prefix.dup,
          mixed_content: mixed_content,
          namespace_set: namespace_set?,
          prefix_set: prefix_set?,
          default_namespace: default_namespace.dup,
        )
      end
    end
  end
end
