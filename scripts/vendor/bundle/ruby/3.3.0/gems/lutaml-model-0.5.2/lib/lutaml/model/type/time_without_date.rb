require "time"

module Lutaml
  module Model
    module Type
      class TimeWithoutDate < Value
        # TODO: we probably want to do something like this because using
        # Time.parse will set the date to today.
        #
        # time = ::Time.parse(value.to_s)
        # ::Time.new(1, 1, 1, time.hour, time.min, time.sec)

        def self.cast(value)
          return nil if value.nil?

          case value
          when ::Time then value
          else ::Time.parse(value.to_s)
          end
        rescue ArgumentError
          nil
        end

        def self.serialize(value)
          return nil if value.nil?

          value = cast(value)
          value.strftime("%H:%M:%S") # Format as HH:MM:SS
        end

        # Instance methods for format-specific serialization
        def to_xml
          self.class.serialize(value)
        end

        def to_json(*_args)
          self.class.serialize(value)
        end

        def to_yaml
          self.class.serialize(value)
        end

        def to_toml
          value.strftime("%H:%M:%S.%L") # Include milliseconds for TOML
        end
      end
    end
  end
end
