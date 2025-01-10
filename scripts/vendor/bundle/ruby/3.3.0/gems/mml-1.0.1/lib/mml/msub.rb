# frozen_string_literal: true

module Mml
  class Msub < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:msub)

    attribute :mathbackground, :string
    attribute :subscriptshift, :string
    attribute :mathcolor, :string
    Mml::Configuration::SUPPORTED_TAGS.each do |tag|
      attribute :"#{tag}_value", Mml.const_get(tag.capitalize), collection: true
    end

    xml do
      root "msub", mixed: true

      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "subscriptshift", to: :subscriptshift, namespace: nil
      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      Mml::Configuration::SUPPORTED_TAGS.each do |tag|
        map_element tag.to_sym, to: :"#{tag}_value"
      end
    end
  end
end
