# frozen_string_literal: true

module Mml
  class Munderover < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:munderover)

    attribute :mathcolor, :string
    attribute :mathbackground, :string
    attribute :accent, :string
    attribute :accentunder, :string
    attribute :align, :string
    Mml::Configuration::SUPPORTED_TAGS.each do |tag|
      attribute :"#{tag}_value", Mml.const_get(tag.capitalize), collection: true
    end

    xml do
      root "munderover", mixed: true

      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "accent", to: :accent, namespace: nil
      map_attribute "accentunder", to: :accentunder, namespace: nil
      map_attribute "align", to: :align, namespace: nil
      Mml::Configuration::SUPPORTED_TAGS.each do |tag|
        map_element tag.to_sym, to: :"#{tag}_value"
      end
    end
  end
end
