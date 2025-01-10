module Lutaml
  module Model
    class Location
      attr_reader :namespace, :location

      def initialize(namespace:, location:)
        @namespace = namespace
        @location = location
      end

      def to_xml_attribute
        "#{@namespace} #{@location}".strip
      end
    end

    class SchemaLocation
      DEFAULT_NAMESPACE = "http://www.w3.org/2001/XMLSchema-instance".freeze

      attr_reader :namespace, :prefix, :schema_location

      def initialize(schema_location:, prefix: "xsi",
namespace: DEFAULT_NAMESPACE)
        @original_schema_location = schema_location
        @schema_location = parsed_schema_locations(schema_location)
        @prefix = prefix
        @namespace = namespace
      end

      def to_xml_attributes
        {
          "xmlns:#{prefix}" => namespace,
          "#{prefix}:schemaLocation" => schema_location.map(&:to_xml_attribute).join(" "),
        }
      end

      def [](index)
        @schema_location[index]
      end

      def size
        @schema_location.size
      end

      private

      def parsed_schema_locations(schema_location)
        locations = if schema_location.is_a?(Hash)
                      schema_location
                    else
                      schema_location.split.each_slice(2)
                    end

        locations.map do |n, l|
          Location.new(namespace: n, location: l)
        end
      end
    end
  end
end
