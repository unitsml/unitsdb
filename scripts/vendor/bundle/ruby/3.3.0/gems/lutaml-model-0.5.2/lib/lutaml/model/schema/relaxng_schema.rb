require "nokogiri"

module Lutaml
  module Model
    module Schema
      class RelaxngSchema
        def self.generate(klass, options = {})
          builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
            xml.grammar(xmlns: "http://relaxng.org/ns/structure/1.0") do
              generate_start(xml, klass)
              generate_define(xml, klass)
            end
          end

          options[:pretty] ? builder.to_xml(indent: 2) : builder.to_xml
        end

        def self.generate_start(xml, klass)
          xml.start do
            xml.ref(name: klass.name)
          end
        end

        def self.generate_attributes(xml, klass)
          klass.attributes.each do |name, attr|
            if attr.type <= Lutaml::Model::Serialize
              xml.ref(name: attr.type.name)
            elsif attr.collection?
              xml.zeroOrMore do
                xml.element(name: name) do
                  xml.data(type: get_relaxng_type(attr.type))
                end
              end
            else
              xml.element(name: name) do
                xml.data(type: get_relaxng_type(attr.type))
              end
            end
          end
        end

        def self.generate_define(xml, klass)
          xml.define(name: klass.name) do
            xml.element(name: klass.name) do
              generate_attributes(xml, klass)
            end
          end

          klass.attributes.each_value do |attr|
            if attr.type <= Lutaml::Model::Serialize
              generate_define(xml, attr.type)
            end
          end
        end

        def self.get_relaxng_type(type)
          {
            Lutaml::Model::Type::String => "string",
            Lutaml::Model::Type::Integer => "integer",
            Lutaml::Model::Type::Boolean => "boolean",
            Lutaml::Model::Type::Float => "float",
            Lutaml::Model::Type::Decimal => "decimal",
            Lutaml::Model::Type::Hash => "string",
          }[type] || "string" # Default to string for unknown types
        end
      end
    end
  end
end
