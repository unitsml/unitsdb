# frozen_string_literal: true

module Mml
  class Semantics < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:semantics)

    attribute :annotation, Mml::Mi, collection: true
    Mml::Configuration::SUPPORTED_TAGS.each do |tag|
      attribute :"#{tag}_value", Mml.const_get(tag.capitalize), collection: true
    end

    xml do
      root "semantics", mixed: true

      map_element :annotation, to: :annotation
      Mml::Configuration::SUPPORTED_TAGS.each do |tag|
        map_element tag.to_sym, to: :"#{tag}_value"
      end
    end
  end
end
