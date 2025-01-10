module Lutaml
  module Model
    class Attribute
      attr_reader :name, :type, :options

      ALLOWED_OPTIONS = %i[
        raw
        default
        delegate
        collection
        values
        pattern
      ].freeze

      def initialize(name, type, options = {})
        @name = name

        validate_type!(type)
        @type = cast_type!(type)

        validate_options!(options)
        @options = options

        @raw = !!options[:raw]

        if collection?
          validate_collection_range
          @options[:default] = -> { [] } unless options[:default]
        end
      end

      def delegate
        @options[:delegate]
      end

      def cast_type!(type)
        case type
        when Symbol
          begin
            Type.lookup(type)
          rescue UnknownTypeError
            raise ArgumentError, "Unknown Lutaml::Model::Type: #{type}"
          end
        when String
          begin
            Type.const_get(type)
          rescue NameError
            raise ArgumentError, "Unknown Lutaml::Model::Type: #{type}"
          end
        when Class
          type
        else
          raise ArgumentError, "Unknown Lutaml::Model::Type: #{type}"
        end
      end

      def cast_value(value)
        return type.cast(value) unless value.is_a?(Array)

        value.map { |v| type.cast(v) }
      end

      def setter
        :"#{@name}="
      end

      def collection?
        options[:collection] || false
      end

      def singular?
        !collection?
      end

      def raw?
        @raw
      end

      def enum?
        !enum_values.empty?
      end

      def default
        value = if delegate
                  type.attributes[to].default
                elsif options[:default].is_a?(Proc)
                  options[:default].call
                else
                  options[:default]
                end

        cast_value(value)
      end

      def pattern
        options[:pattern]
      end

      def enum_values
        @options.key?(:values) ? @options[:values] : []
      end

      def valid_value!(value)
        return true if value.nil? && !collection?
        return true unless enum?

        unless valid_value?(value)
          raise Lutaml::Model::InvalidValueError.new(name, value, enum_values)
        end

        true
      end

      def valid_value?(value)
        return true unless options[:values]

        options[:values].include?(value)
      end

      def valid_pattern!(value)
        return true unless type == Lutaml::Model::Type::String
        return true unless pattern

        unless pattern.match?(value)
          raise Lutaml::Model::PatternNotMatchedError.new(name, pattern, value)
        end

        true
      end

      # Check if the value to be assigned is valid for the attribute
      #
      # Currently there are 2 validations
      #   1. Value should be from the values list if they are defined
      #      e.g values: ["foo", "bar"] is set then any other value for this
      #          attribute will raise `Lutaml::Model::InvalidValueError`
      #
      #   2. Value count should be between the collection range if defined
      #      e.g if collection: 0..5 is set then the value greater then 5
      #          will raise `Lutaml::Model::CollectionCountOutOfRangeError`
      def validate_value!(value)
        # Use the default value if the value is nil
        value = default if value.nil?

        valid_value!(value) && valid_collection!(value, self) && valid_pattern!(value)
      end

      def validate_collection_range
        range = @options[:collection]
        return if range == true

        unless range.is_a?(Range)
          raise ArgumentError, "Invalid collection range: #{range}"
        end

        if range.begin.nil?
          raise ArgumentError,
                "Invalid collection range: #{range}. Begin must be specified."
        end

        if range.begin.negative?
          raise ArgumentError,
                "Invalid collection range: #{range}. Begin must be non-negative."
        end

        if range.end && range.end < range.begin
          raise ArgumentError,
                "Invalid collection range: #{range}. End must be greater than or equal to begin."
        end
      end

      def valid_collection!(value, caller)
        raise Lutaml::Model::CollectionTrueMissingError.new(name, caller) if value.is_a?(Array) && !collection?

        return true unless collection?

        # Allow nil values for collections during initialization
        return true if value.nil?

        # Allow any value for unbounded collections
        return true if options[:collection] == true

        unless value.is_a?(Array)
          raise Lutaml::Model::CollectionCountOutOfRangeError.new(
            name,
            value,
            options[:collection],
          )
        end

        range = options[:collection]
        return true unless range.is_a?(Range)

        if range.end.nil?
          if value.size < range.begin
            raise Lutaml::Model::CollectionCountOutOfRangeError.new(
              name,
              value,
              range,
            )
          end
        elsif !range.cover?(value.size)
          raise Lutaml::Model::CollectionCountOutOfRangeError.new(
            name,
            value,
            range,
          )
        end
      end

      def serialize(value, format, options = {})
        return if value.nil?

        if value.is_a?(Array)
          value.map do |v|
            serialize(v, format, options)
          end
        elsif type <= Serialize
          if Utils.present?(value)
            type.public_send(:"as_#{format}", value, options)
          end
        else
          # Convert to Value instance if not already
          value = type.new(value) unless value.is_a?(Type::Value)
          value.send(:"to_#{format}")
        end
      end

      def cast(value, format, options = {})
        value ||= [] if collection?

        if value.is_a?(Array)
          value.map do |v|
            cast(v, format, options)
          end
        elsif type <= Serialize && value.is_a?(Hash)
          type.apply_mappings(value, format, options)
        else
          type.cast(value)
        end
      end

      private

      def validate_options!(options)
        if (invalid_opts = options.keys - ALLOWED_OPTIONS).any?
          raise StandardError,
                "Invalid options given for `#{name}` #{invalid_opts}"
        end

        if options.key?(:pattern) && type != Lutaml::Model::Type::String
          raise StandardError,
                "Invalid option `pattern` given for `#{name}`, `pattern` is only allowed for :string type"
        end

        true
      end

      def validate_type!(type)
        return true if type.is_a?(Class)
        return true if [Symbol, String].include?(type.class) && cast_type!(type)

        raise ArgumentError,
              "Invalid type: #{type}, must be a Symbol, String or a Class"
      end
    end
  end
end
