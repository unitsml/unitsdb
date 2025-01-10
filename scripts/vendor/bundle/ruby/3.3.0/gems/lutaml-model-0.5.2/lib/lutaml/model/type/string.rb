module Lutaml
  module Model
    module Type
      class String < Value
        def self.cast(value)
          return nil if value.nil?

          value.to_s
        end

        # xs:string format
        def to_xml
          value&.to_s
        end

        # JSON string
        def to_json(*_args)
          value
        end

        # YAML string
        def to_yaml
          value
        end

        # TOML string
        def to_toml
          value&.to_s
        end

        def self.from_xml(value)
          cast(value)
        end

        def self.from_json(value)
          cast(value)
        end

        def self.from_yaml(value)
          cast(value)
        end

        def self.from_toml(value)
          cast(value)
        end
      end
    end
  end
end
