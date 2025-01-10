# frozen_string_literal: true

module Mml
  class Munder < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:munder)

    attribute :mathbackground, :string
    attribute :accentunder, :string
    attribute :mathcolor, :string
    attribute :content, :string
    attribute :align, :string
    Mml::Configuration::SUPPORTED_TAGS.each do |tag|
      attribute :"#{tag}_value", Mml.const_get(tag.capitalize), collection: true
    end

    xml do
      root "munder", mixed: true

      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "accentunder", to: :accentunder, namespace: nil
      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "align", to: :align, namespace: nil
      map_content to: :content
      Mml::Configuration::SUPPORTED_TAGS.each do |tag|
        map_element tag.to_sym, to: :"#{tag}_value"
      end
    end
  end
end
