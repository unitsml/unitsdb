# frozen_string_literal: true

module Lutaml
  module Model
    module XmlAdapter
      module Oga
        class Document < ::Oga::XML::Document
          def initialize(options = {})
            super
          end

          def text(value = nil)
            children << ::Oga::XML::Text.new(text: value)
            self
          end
        end
      end
    end
  end
end
