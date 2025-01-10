# frozen_string_literal: true

module Mml
  class Mfenced < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:mfenced)

    attribute :mathbackground, :string
    attribute :separators, :string
    attribute :mathcolor, :string
    attribute :content, :string
    attribute :close, :string
    attribute :open, :string
    Mml::Configuration::SUPPORTED_TAGS.each do |tag|
      attribute :"#{tag}_value", Mml.const_get(tag.capitalize), collection: true
    end

    xml do
      root "mfenced", mixed: true

      map_content to: :content

      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "separators", to: :separators, namespace: nil
      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "close", to: :close, namespace: nil
      map_attribute "open", to: :open, namespace: nil

      Mml::Configuration::SUPPORTED_TAGS.each do |tag|
        map_element tag.to_sym, to: :"#{tag}_value"
      end
    end
  end
end
