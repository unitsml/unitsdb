# frozen_string_literal: true

module Mml
  class Mscarries < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:mscarries)

    attribute :scriptsizemultiplier, :integer
    attribute :mathbackground, :string
    attribute :mathcolor, :string
    attribute :position, :integer
    attribute :location, :string
    attribute :crossout, :string
    Mml::Configuration::SUPPORTED_TAGS.each do |tag|
      attribute :"#{tag}_value", Mml.const_get(tag.capitalize), collection: true
    end

    xml do
      root "mscarries", mixed: true

      map_attribute "scriptsizemultiplier", to: :scriptsizemultiplier, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "position", to: :position, namespace: nil
      map_attribute "location", to: :location, namespace: nil
      map_attribute "crossout", to: :crossout, namespace: nil
      Mml::Configuration::SUPPORTED_TAGS.each do |tag|
        map_element tag.to_sym, to: :"#{tag}_value"
      end
    end
  end
end
