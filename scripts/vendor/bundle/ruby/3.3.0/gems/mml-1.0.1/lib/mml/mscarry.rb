# frozen_string_literal: true

module Mml
  class Mscarry < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:mscarry)

    attribute :mathcolor, :string
    attribute :mathbackground, :string
    attribute :location, :string
    attribute :crossout, :string
    Mml::Configuration::SUPPORTED_TAGS.each do |tag|
      attribute :"#{tag}_value", Mml.const_get(tag.capitalize), collection: true
    end

    xml do
      root "mscarry", mixed: true

      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "location", to: :location, namespace: nil
      map_attribute "crossout", to: :crossout, namespace: nil
      Mml::Configuration::SUPPORTED_TAGS.each do |tag|
        map_element tag.to_sym, to: :"#{tag}_value"
      end
    end
  end
end
