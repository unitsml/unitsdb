module Lutaml
  module Model
    module Validation
      def validate
        errors = []
        self.class.attributes.each do |name, attr|
          value = public_send(:"#{name}")
          begin
            if value.respond_to?(:validate!)
              value.validate!
            else
              attr.validate_value!(value)
            end
          rescue Lutaml::Model::InvalidValueError,
                 Lutaml::Model::CollectionCountOutOfRangeError,
                 PatternNotMatchedError => e
            errors << e
          end
        end
        errors
      end

      def validate!
        errors = validate
        raise Lutaml::Model::ValidationError.new(errors) if errors.any?
      end
    end
  end
end
