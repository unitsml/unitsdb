require_relative "xml_attribute"

module Lutaml
  module Model
    module XmlAdapter
      class XmlElement
        attr_reader :attributes,
                    :children,
                    :text,
                    :namespace_prefix,
                    :parent_document

        attr_accessor :adapter_node

        def initialize(
          node,
          attributes = {},
          children = [],
          text = nil,
          parent_document: nil,
          namespace_prefix: nil,
          default_namespace: nil
        )
          @name = extract_name(node)
          @namespace_prefix = namespace_prefix || extract_namespace_prefix(node)
          @attributes = attributes
          @children = children
          @text = text
          @parent_document = parent_document
          @default_namespace = default_namespace

          self.adapter_node = node
        end

        # This tells which attributes to pretty print, So we remove the
        # @parent_document and @adapter_node because they were causing
        # so much repeatative output.
        def pretty_print_instance_variables
          (instance_variables - %i[@adapter_node @parent_document]).sort
        end

        def name
          return @name unless namespace_prefix

          "#{namespace_prefix}:#{@name}"
        end

        def namespaced_name
          if namespaces[namespace_prefix] && !text?
            "#{namespaces[namespace_prefix].uri}:#{@name}"
          elsif @default_namespace && !text?
            "#{@default_namespace}:#{name}"
          else
            @name
          end
        end

        def unprefixed_name
          @name
        end

        def document
          XmlDocument.new(self)
        end

        def namespaces
          @namespaces || @parent_document&.namespaces || {}
        end

        def own_namespaces
          @namespaces || {}
        end

        def namespace
          return default_namespace unless namespace_prefix

          namespaces[namespace_prefix]
        end

        def attribute_is_namespace?(name)
          name.to_s.start_with?("xmlns")
        end

        def add_namespace(namespace)
          @namespaces ||= {}
          @namespaces[namespace.prefix] = namespace
        end

        def default_namespace
          namespaces[nil] || @parent_document&.namespaces&.dig(nil)
        end

        def extract_name(node)
          name = name_from_node(node)

          n = name.split(":")
          return name if n.length <= 1

          n[1..].join(":")
        end

        def extract_namespace_prefix(node)
          name = name_from_node(node)

          n = name.to_s.split(":")
          return if n.length <= 1

          n.first
        end

        def name_from_node(node)
          if node.is_a?(String)
            node
          else
            node.name.to_s
          end
        end

        def order
          children.each_with_object([]) do |child, arr|
            arr << child.unprefixed_name
          end
        end
      end
    end
  end
end
