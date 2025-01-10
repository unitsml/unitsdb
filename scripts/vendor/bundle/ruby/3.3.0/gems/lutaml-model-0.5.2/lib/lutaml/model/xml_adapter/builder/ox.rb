module Lutaml
  module Model
    module XmlAdapter
      module Builder
        class Ox
          def self.build(options = {})
            if block_given?
              ::Ox::Builder.new(options) do |xml|
                yield(new(xml))
              end
            else
              new(::Ox::Builder.new(options))
            end
          end

          attr_reader :xml

          def initialize(xml)
            @xml = xml
            @current_namespace = nil
          end

          def create_element(name, attributes = {})
            if @current_namespace && !name.start_with?("#{@current_namespace}:")
              name = "#{@current_namespace}:#{name}"
            end

            if block_given?
              xml.element(name, attributes) do |element|
                yield(self.class.new(element))
              end
            else
              xml.element(name, attributes)
            end
          end

          def add_element(element, child)
            element << child
          end

          def add_attribute(element, name, value)
            element[name] = value
          end

          def create_and_add_element(element_name, prefix: nil, attributes: {})
            element_name = element_name.first if element_name.is_a?(Array)
            prefixed_name = if prefix
                              "#{prefix}:#{element_name}"
                            elsif @current_namespace && !element_name.start_with?("#{@current_namespace}:")
                              "#{@current_namespace}:#{element_name}"
                            else
                              element_name
                            end

            if block_given?
              xml.element(prefixed_name, attributes) do |element|
                yield(self.class.new(element))
              end
            else
              xml.element(prefixed_name, attributes)
            end

            @current_namespace = nil
          end

          def <<(text)
            xml.text(text)
          end

          def add_xml_fragment(element, content)
            element.raw(content)
          end

          def add_text(element, text, cdata: false)
            return element.cdata(text) if cdata

            element.text(text)
          end

          def add_cdata(element, value)
            element.cdata(value)
          end

          # Add XML namespace to document
          #
          # Ox doesn't support XML namespaces so we only save the
          # current namespace prefix to add it to the element's name later.
          def add_namespace_prefix(prefix)
            @current_namespace = prefix
            self
          end

          def parent
            xml
          end

          def method_missing(method_name, *args)
            if block_given?
              xml.public_send(method_name, *args) do
                yield(xml)
              end
            else
              xml.public_send(method_name, *args)
            end
          end

          def respond_to_missing?(method_name, include_private = false)
            xml.respond_to?(method_name) || super
          end
        end
      end
    end
  end
end
