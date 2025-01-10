# frozen_string_literal: true

module Lutaml
  module Model
    module XmlAdapter
      module Builder
        class Oga
          def self.build(options = {}, &block)
            if block_given?
              XmlAdapter::Builder::Oga.new(options, &block)
            else
              XmlAdapter::Builder::Oga.new(options)
            end
          end

          attr_reader :document, :current_node, :options

          def initialize(options = {})
            @document = XmlAdapter::Oga::Document.new
            @current_node = @document
            @options = options
            yield(self) if block_given?
          end

          def create_element(name, attributes = {}, &block)
            if @current_namespace && !name.start_with?("#{@current_namespace}:")
              name = "#{@current_namespace}:#{name}"
            end

            if block_given?
              element(name, attributes, &block)
            else
              element(name, attributes)
            end
          end

          def element(name, attributes = {})
            oga_element = ::Oga::XML::Element.new(name: name)
            if block_given?
              element_attributes(oga_element, attributes)
              @current_node.children << oga_element
              # Save previous node to reset the pointer for the rest of the iteration
              previous_node = @current_node
              # Set current node to new element as pointer for the block
              @current_node = oga_element
              yield(self)
              # Reset the pointer for the rest of the iterations
              @current_node = previous_node
            end
            oga_element
          end

          def add_element(oga_element, child)
            if child.is_a?(String)
              current_element = oga_element.is_a?(XmlAdapter::Oga::Document) ? current_node : oga_element
              add_xml_fragment(current_element, child)
            elsif oga_element.is_a?(XmlAdapter::Oga::Document)
              oga_element.children.last.children << child
            else
              oga_element.children << child
            end
          end

          def add_attribute(element, name, value)
            attribute = ::Oga::XML::Attribute.new(
              name: name,
              value: value.to_s,
            )
            if element.is_a?(XmlAdapter::Oga::Document)
              element.children.last.attributes << attribute
            else
              element.attributes << attribute
            end
          end

          def create_and_add_element(
            element_name,
            prefix: (prefix_unset = true
                     nil),
            attributes: {},
            &block
          )
            @current_namespace = nil if prefix.nil? && !prefix_unset
            prefixed_name = if prefix
                              "#{prefix}:#{element_name}"
                            elsif @current_namespace && !element_name.start_with?("#{@current_namespace}:")
                              "#{@current_namespace}:#{element_name}"
                            else
                              element_name
                            end

            if block_given?
              element(prefixed_name, attributes, &block)
            else
              element(prefixed_name, attributes)
            end
          end

          def <<(text)
            @current_node.text(text)
          end

          def add_xml_fragment(element, content)
            fragment = "<fragment>#{content}</fragment>"
            parsed_fragment = ::Oga.parse_xml(fragment)
            parsed_children = parsed_fragment.children.first.children
            if element.is_a?(XmlAdapter::Oga::Document)
              element.children.last.children += parsed_children
            else
              element.children += parsed_children
            end
          end

          def add_text(element, text, cdata: false)
            return add_cdata(element, text) if cdata

            oga_text = ::Oga::XML::Text.new(text: text.to_s)
            if element.is_a?(XmlAdapter::Oga::Document)
              children = element.children
              children.empty? ? children << oga_text : children.last.children << oga_text
            else
              element.children << oga_text
            end
          end

          def add_cdata(element, value)
            oga_cdata = ::Oga::XML::CData.new(text: value.to_s)
            if element.is_a?(XmlAdapter::Oga::Document)
              element.children.last.children << oga_cdata
            else
              element.children << oga_cdata
            end
          end

          def add_namespace_prefix(prefix)
            @current_namespace = prefix
            self
          end

          def parent
            @document
          end

          def text(value = nil)
            return @current_node.inner_text if value.nil?

            str = value.is_a?(Array) ? value.join : value
            @current_node.children << ::Oga::XML::Text.new(text: str)
          end

          def method_missing(method_name, *args)
            if block_given?
              @current_node.public_send(method_name, *args) do
                yield(self)
              end
            else
              @current_node.public_send(method_name, *args)
            end
          end

          def respond_to_missing?(method_name, include_private = false)
            @current_node.respond_to?(method_name) || super
          end

          private

          def element_attributes(oga_element, attributes)
            oga_element.attributes = attributes.map do |name, value|
              ::Oga::XML::Attribute.new(
                name: name,
                value: value,
                element: oga_element,
              )
            end
          end
        end
      end
    end
  end
end
