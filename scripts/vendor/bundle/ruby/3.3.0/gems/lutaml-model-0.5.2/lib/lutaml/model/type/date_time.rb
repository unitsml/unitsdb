require "date"

module Lutaml
  module Model
    module Type
      # Date and time representation
      class DateTime < Value
        def self.cast(value)
          return nil if value.nil?

          case value
          when ::DateTime then value
          when ::Time then value.to_datetime
          else ::DateTime.parse(value.to_s)
          end
        rescue ArgumentError
          nil
        end

        def self.serialize(value)
          return nil if value.nil?

          cast(value)&.iso8601
        end

        # xs:dateTime format (ISO8601 with timezone)
        def to_xml
          value&.iso8601
        end

        # RFC3339 (ISO8601 with timezone)
        def to_json(*_args)
          value&.iso8601
        end

        # YAML timestamp format (native)
        def to_yaml
          value&.iso8601
        end

        # TOML datetime format (RFC3339)
        def to_toml
          value&.iso8601
        end
      end
    end
  end
end
