# frozen_striing_literal: true

module Lutaml
  module Model
    module XmlAdapter
      class XmlNamespace
        # Return name
        #
        # @return [String]
        #
        # @api private
        attr_accessor :uri

        # Return prefix
        #
        # @return [String]
        #
        # @api private
        attr_accessor :prefix

        # Initialize instance
        #
        # @param [String, nil] name
        # @param [String, nil] prefix
        #
        # @api private
        def initialize(uri = nil, prefix = nil)
          @uri = uri
          @prefix = normalize_prefix(prefix)
        end

        def normalize_prefix(prefix)
          normalized_prefix = prefix.to_s.gsub(/xmlns:?/, "")
          return if normalized_prefix.empty?

          normalized_prefix
        end

        def attr_name
          if Utils.present?(prefix)
            "xmlns:#{prefix}"
          else
            "xmlns"
          end
        end
      end
    end
  end
end
