# frozen_string_literal: true

module Mml
  class Mrow < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:mrow)

    attribute :mathbackground, :string
    attribute :mathcolor, :string
    attribute :content, :string
    attribute :intent, :string
    attribute :dir, :string

    Mml::Configuration::SUPPORTED_TAGS.each do |tag|
      attribute :"#{tag}_value", Mml.const_get(tag.capitalize), collection: true
    end

    xml do
      root "mrow", mixed: true

      map_content to: :content
      map_attribute "dir", to: :dir, namespace: nil
      map_attribute "intent", to: :intent, namespace: nil
      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil

      Mml::Configuration::SUPPORTED_TAGS.each do |tag|
        map_element tag, to: :"#{tag}_value"
      end
    end
  end
end
