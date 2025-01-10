module Lutaml
  module Model
    module Type
      class Date < Value
        def self.cast(value)
          return nil if value.nil?

          case value
          when ::DateTime, ::Time
            value.to_date
          when ::Date
            value
          else
            ::Date.parse(value.to_s)
          end
        rescue ArgumentError
          nil
        end

        # xs:date format
        def self.serialize(value)
          return nil if value.nil?

          value&.iso8601
        end

        # This is to handle where Ruby's YAML safe_load does not handle
        # the Date/Time classes
        def to_yaml
          value&.iso8601.to_s
        end
      end
    end
  end
end
