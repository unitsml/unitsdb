# frozen_string_literal: true

module Mml
  class Msrow < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:msrow)

    attribute :mathcolor, :string
    attribute :mathbackground, :string
    attribute :position, :integer
    Mml::Configuration::SUPPORTED_TAGS.each do |tag|
      attribute :"#{tag}_value", Mml.const_get(tag.capitalize), collection: true
    end

    xml do
      root "msrow", mixed: true

      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "position", to: :position, namespace: nil

      Mml::Configuration::SUPPORTED_TAGS.each do |tag|
        map_element tag, to: :"#{tag}_value"
      end
    end
  end
end
