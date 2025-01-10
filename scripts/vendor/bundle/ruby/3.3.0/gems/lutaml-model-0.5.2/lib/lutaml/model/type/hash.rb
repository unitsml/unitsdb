module Lutaml
  module Model
    module Type
      class Hash < Value
        def self.cast(value)
          return nil if value.nil?

          hash = if value.respond_to?(:to_h)
                   value.to_h
                 else
                   Hash(value)
                 end

          normalize_hash(hash)
        end

        def self.normalize_hash(hash)
          return hash["text"] if hash.keys == ["text"]

          hash = hash.to_h if hash.is_a?(Lutaml::Model::MappingHash)

          hash = hash.except("text")

          hash.transform_values do |value|
            if value.is_a?(::Hash)
              # Only process if value is a Hash
              nested = normalize_hash(value)
              # Only include non-text nodes in nested hashes if it's a hash
              nested.is_a?(::Hash) ? nested.except("text") : nested
            else
              value
            end
          end
        end

        def self.serialize(value)
          return nil if value.nil?
          return value if value.is_a?(Hash)

          value.respond_to?(:to_h) ? value.to_h : Hash(value)
        end

        # Format-specific serialization methods
        def to_xml
          value
        end

        def to_json(*_args)
          value
        end

        def to_yaml
          value
        end

        def to_toml
          value
        end
      end
    end
  end
end
