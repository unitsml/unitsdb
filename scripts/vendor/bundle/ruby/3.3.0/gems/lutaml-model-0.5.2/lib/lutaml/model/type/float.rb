module Lutaml
  module Model
    module Type
      class Float < Value
        def self.cast(value)
          return nil if value.nil?

          value.to_f
        end

        def self.serialize(value)
          return nil if value.nil?

          cast(value)
        end

        # Instance methods for specific formats
        # xs:float format
        def to_xml
          value.to_s
        end

        def to_yaml
          value
        end

        def to_json(*_args)
          value
        end

        def to_yaml
          value
        end
      end
    end
  end
end
