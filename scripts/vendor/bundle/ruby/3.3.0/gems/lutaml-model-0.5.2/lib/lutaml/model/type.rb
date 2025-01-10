module Lutaml
  module Model
    module Type
      TYPE_CODES = {
        string: "Lutaml::Model::Type::String",
        integer: "Lutaml::Model::Type::Integer",
        float: "Lutaml::Model::Type::Float",
        decimal: "Lutaml::Model::Type::Decimal",
        date: "Lutaml::Model::Type::Date",
        time: "Lutaml::Model::Type::Time",
        date_time: "Lutaml::Model::Type::DateTime",
        time_without_date: "Lutaml::Model::Type::TimeWithoutDate",
        boolean: "Lutaml::Model::Type::Boolean",
        hash: "Lutaml::Model::Type::Hash",
      }.freeze

      class << self
        def register_builtin_types
          TYPE_CODES.each do |type_name, type_class|
            register(type_name, const_get(type_class))
          end
        end

        def register(type_name, type_class)
          unless type_class < Value
            raise TypeError,
                  "class '#{type_class}' is not a valid Lutaml::Model::Type::Value"
          end

          @registry ||= {}
          @registry[type_name.to_sym] = type_class
        end

        def lookup(type_name)
          @registry ||= {}
          klass = @registry[type_name.to_sym]

          raise UnknownTypeError.new(type_name) unless klass

          klass
        end

        def cast(value, type)
          return nil if value.nil?

          type.cast(value)
        end

        def serialize(value, type)
          return nil if value.nil?

          type.serialize(value)
        end
      end
    end
  end
end

# Register built-in types
require_relative "type/value"
require_relative "type/string"
require_relative "type/integer"
require_relative "type/float"
require_relative "type/date"
require_relative "type/time"
require_relative "type/date_time"
require_relative "type/time_without_date"
require_relative "type/boolean"
require_relative "type/decimal"
require_relative "type/hash"

Lutaml::Model::Type.register_builtin_types
