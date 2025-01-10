# frozen_string_literal: true

module Mml
  class Mlongdiv < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:mlongdiv)

    attribute :mathbackground, :string
    attribute :longdivstyle, :string
    attribute :mathcolor, :string
    attribute :position, :integer
    attribute :shift, :integer
    Mml::Configuration::SUPPORTED_TAGS.each do |tag|
      attribute :"#{tag}_value", Mml.const_get(tag.capitalize), collection: true
    end

    xml do
      root "mlongdiv", mixed: true

      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "longdivstyle", to: :longdivstyle, namespace: nil
      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "position", to: :position, namespace: nil
      map_attribute "shift", to: :shift, namespace: nil
      Mml::Configuration::SUPPORTED_TAGS.each do |tag|
        map_element tag.to_sym, to: :"#{tag}_value"
      end
    end
  end
end
