module Lutaml
  module Model
    module Type
      class Boolean < Value
        def self.cast(value)
          return nil if value.nil?
          return true if value == true || value.to_s.match?(/^(true|t|yes|y|1)$/i)
          return false if value == false || value.to_s.match?(/^(false|f|no|n|0)$/i)

          value
        end

        def self.serialize(value)
          return nil if value.nil?

          cast(value) # Return actual boolean instead of string
        end

        # Format-specific serialization methods
        def to_xml
          value.to_s
        end

        def to_json(*_args)
          value
        end

        def to_yaml
          value
        end

        def to_toml
          value.to_s
        end
      end
    end
  end
end
