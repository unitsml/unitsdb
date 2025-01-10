# frozen_string_literal: true

module Mml
  class Mstack < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:mstack)

    attribute :mathcolor, :string
    attribute :mathbackground, :string
    attribute :align, :string
    attribute :stackalign, :string
    attribute :charalign, :string
    attribute :charspacing, :string
    Mml::Configuration::SUPPORTED_TAGS.each do |tag|
      attribute :"#{tag}_value", Mml.const_get(tag.capitalize), collection: true
    end

    xml do
      root "mstack", mixed: true

      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "align", to: :align, namespace: nil
      map_attribute "stackalign", to: :stackalign, namespace: nil
      map_attribute "charalign", to: :charalign, namespace: nil
      map_attribute "charspacing", to: :charspacing, namespace: nil
      Mml::Configuration::SUPPORTED_TAGS.each do |tag|
        map_element tag, to: :"#{tag}_value"
      end
    end
  end
end
