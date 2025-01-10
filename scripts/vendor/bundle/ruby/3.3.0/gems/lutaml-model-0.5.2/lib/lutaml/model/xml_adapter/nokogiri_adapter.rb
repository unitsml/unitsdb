require "nokogiri"
require_relative "xml_document"
require_relative "builder/nokogiri"

module Lutaml
  module Model
    module XmlAdapter
      class NokogiriAdapter < XmlDocument
        def self.parse(xml, options = {})
          parsed = Nokogiri::XML(xml, nil, options[:encoding])
          root = NokogiriElement.new(parsed.root)
          new(root, parsed.encoding)
        end

        def to_xml(options = {})
          builder_options = {}

          if options.key?(:encoding)
            builder_options[:encoding] = options[:encoding] unless options[:encoding].nil?
          elsif options.key?(:parse_encoding)
            builder_options[:encoding] = options[:parse_encoding]
          else
            builder_options[:encoding] = "UTF-8"
          end

          builder = Builder::Nokogiri.build(builder_options) do |xml|
            if root.is_a?(Lutaml::Model::XmlAdapter::NokogiriElement)
              root.build_xml(xml)
            else
              mapper_class = options[:mapper_class] || @root.class
              options[:xml_attributes] =
                build_namespace_attributes(mapper_class)
              build_element(xml, @root, options)
            end
          end

          xml_options = {}
          xml_options[:indent] = 2 if options[:pretty]

          xml_data = builder.doc.root.to_xml(xml_options)
          options[:declaration] ? declaration(options) + xml_data : xml_data
        end

        private

        def prefix_xml(xml, mapping, options)
          if options.key?(:namespace_prefix)
            xml[options[:namespace_prefix]] if options[:namespace_prefix]
          elsif mapping.namespace_prefix
            xml[mapping.namespace_prefix]
          end
          xml
        end

        def build_ordered_element(xml, element, options = {})
          mapper_class = options[:mapper_class] || element.class
          xml_mapping = mapper_class.mappings_for(:xml)
          return xml unless xml_mapping

          attributes = build_attributes(element, xml_mapping)&.compact

          prefixed_xml = prefix_xml(xml, xml_mapping, options)

          tag_name = options[:tag_name] || xml_mapping.root_element
          tag_name = "#{tag_name}_" if prefixed_xml.respond_to?(tag_name)
          prefixed_xml.public_send(tag_name, attributes) do
            if options.key?(:namespace_prefix) && !options[:namespace_prefix]
              xml.parent.namespace = nil
            end

            index_hash = {}
            content = []

            element.element_order.each do |name|
              index_hash[name] ||= -1
              curr_index = index_hash[name] += 1

              element_rule = xml_mapping.find_by_name(name)
              next if element_rule.nil?

              attribute_def = attribute_definition_for(element, element_rule,
                                                       mapper_class: mapper_class)
              value = attribute_value_for(element, element_rule)

              if element_rule == xml_mapping.content_mapping
                next if element_rule.cdata && name == "text"

                text = xml_mapping.content_mapping.serialize(element)
                text = text[curr_index] if text.is_a?(Array)

                next prefixed_xml.add_text(xml, text, cdata: element_rule.cdata) if element.mixed?

                content << text
              elsif !value.nil? || element_rule.render_nil?
                value = value[curr_index] if attribute_def.collection?

                add_to_xml(
                  xml,
                  element,
                  element_rule.prefix,
                  value,
                  options.merge(
                    attribute: attribute_def,
                    rule: element_rule,
                    mapper_class: mapper_class,
                  ),
                )
              end
            end

            prefixed_xml.text content.join
          end
        end
      end

      class NokogiriElement < XmlElement
        def initialize(node, root_node: nil, default_namespace: nil)
          if root_node
            node.namespaces.each do |prefix, name|
              namespace = XmlNamespace.new(name, prefix)

              root_node.add_namespace(namespace)
            end
          end

          attributes = {}
          node.attributes.transform_values do |attr|
            name = if attr.namespace
                     "#{attr.namespace.prefix}:#{attr.name}"
                   else
                     attr.name
                   end

            attributes[name] = XmlAttribute.new(
              name,
              attr.value,
              namespace: attr.namespace&.href,
              namespace_prefix: attr.namespace&.prefix,
            )
          end

          if root_node.nil? && !node.namespace&.prefix
            default_namespace = node.namespace&.href
          end

          super(
            node,
            attributes,
            parse_all_children(node, root_node: root_node || self,
                                     default_namespace: default_namespace),
            node.text,
            parent_document: root_node,
            namespace_prefix: node.namespace&.prefix,
            default_namespace: default_namespace
          )
        end

        def text?
          # false
          children.empty? && text.length.positive?
        end

        def to_xml
          return text if text?

          build_xml.doc.root.to_xml
        end

        def inner_xml
          children.map(&:to_xml).join
        end

        def build_xml(builder = nil)
          builder ||= Builder::Nokogiri.build

          if name == "text"
            builder.text(text)
          else
            builder.public_send(name, build_attributes(self)) do |xml|
              children.each do |child|
                child.build_xml(xml)
              end
            end
          end

          builder
        end

        private

        def parse_children(node, root_node: nil)
          node.children.select(&:element?).map do |child|
            NokogiriElement.new(child, root_node: root_node)
          end
        end

        def parse_all_children(node, root_node: nil, default_namespace: nil)
          node.children.map do |child|
            NokogiriElement.new(child, root_node: root_node,
                                       default_namespace: default_namespace)
          end
        end

        def build_attributes(node, _options = {})
          attrs = node.attributes.transform_values(&:value)

          attrs.merge(build_namespace_attributes(node))
        end

        def build_namespace_attributes(node)
          namespace_attrs = {}

          node.own_namespaces.each_value do |namespace|
            namespace_attrs[namespace.attr_name] = namespace.uri
          end

          node.children.each do |child|
            namespace_attrs = namespace_attrs.merge(
              build_namespace_attributes(child),
            )
          end

          namespace_attrs
        end
      end
    end
  end
end
