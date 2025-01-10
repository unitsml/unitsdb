# frozen_string_literal: true

module Mml
  class Mmultiscripts < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:mmultiscripts)

    attribute :mathcolor, :string
    attribute :mathbackground, :string
    attribute :subscriptshift, :string
    attribute :superscriptshift, :string
    attribute :mprescripts_value, Mprescripts
    Mml::Configuration::SUPPORTED_TAGS.each do |tag|
      attribute :"#{tag}_value", Mml.const_get(tag.capitalize), collection: true
    end

    xml do
      root "mmultiscripts", mixed: true

      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "subscriptshift", to: :subscriptshift, namespace: nil
      map_attribute "superscriptshift", to: :superscriptshift, namespace: nil
      map_element "mprescripts", to: :mprescripts_value
      Mml::Configuration::SUPPORTED_TAGS.each do |tag|
        map_element tag.to_sym, to: :"#{tag}_value"
      end
    end
  end
end
