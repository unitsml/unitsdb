# frozen_string_literal: true

module Mml
  class Mtd < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:mtd)

    attribute :mathcolor, :string
    attribute :mathbackground, :string
    attribute :rowalign, :string
    attribute :columnalign, :string
    Mml::Configuration::SUPPORTED_TAGS.each do |tag|
      attribute :"#{tag}_value", Mml.const_get(tag.capitalize), collection: true
    end

    xml do
      root "mtd", mixed: true

      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "rowalign", to: :rowalign, namespace: nil
      map_attribute "columnalign", to: :columnalign, namespace: nil
      Mml::Configuration::SUPPORTED_TAGS.each do |tag|
        map_element tag.to_sym, to: :"#{tag}_value"
      end
    end
  end
end
