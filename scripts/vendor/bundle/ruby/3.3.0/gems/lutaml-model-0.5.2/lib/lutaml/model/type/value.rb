require_relative "../config"

module Lutaml
  module Model
    module Type
      # Base class for all value types
      class Value
        attr_reader :value

        def initialize(value)
          @value = self.class.cast(value)
        end

        def self.cast(value)
          return nil if value.nil?

          value
        end

        def self.serialize(value)
          return nil if value.nil?

          new(value).to_s
        end

        # Instance methods for serialization
        def to_s
          value.to_s
        end

        # Format-specific instance methods
        ::Lutaml::Model::Config::AVAILABLE_FORMATS.each do |format|
          define_method(:"to_#{format}") do
            value
          end
        end

        # Class-level format conversion
        def self.from_format(value, format)
          new(send(:"from_#{format}", value))
        end

        # Default format-specific class methods that can be overridden
        ::Lutaml::Model::Config::AVAILABLE_FORMATS.each do |format|
          define_singleton_method(:"from_#{format}") do |value|
            cast(value)
          end
        end
      end
    end
  end
end
