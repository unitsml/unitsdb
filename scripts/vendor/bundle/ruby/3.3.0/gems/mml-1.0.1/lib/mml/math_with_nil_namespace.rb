# frozen_string_literal: true

module Mml
  class MathWithNilNamespace < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:math)

    Mml::Configuration::SUPPORTED_TAGS.each do |tag|
      attribute :"#{tag}_value", Mml.const_get(tag.capitalize), collection: true
    end

    xml do
      root "math", mixed: true

      Mml::Configuration::SUPPORTED_TAGS.each do |tag|
        map_element tag.to_sym, to: :"#{tag}_value"
      end
    end
  end
end