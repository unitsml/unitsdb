module Lutaml
  module Model
    module Type
      class Integer < Value
        def self.cast(value)
          return nil if value.nil?
          return 1 if value === true
          return 0 if value === false

          case value
          when ::String
            if value.match?(/^0[0-7]+$/) # Octal
              value.to_i(8)
            elsif value.match?(/^-?\d+(\.\d+)?(e-?\d+)?$/i) # Float/exponential
              Float(value).to_i
            else
              begin
                Integer(value, 10)
              rescue StandardError
                nil
              end
            end
          else
            begin
              Integer(value)
            rescue StandardError
              nil
            end
          end
        end

        # Override serialize to return Integer instead of String
        def self.serialize(value)
          return nil if value.nil?

          cast(value)
        end
      end
    end
  end
end
