# frozen_string_literal: true

module Mml
  class Mglyph < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:mglyph)

    attribute :alt, :string
    attribute :src, :string
    attribute :width, :string
    attribute :color, :string
    attribute :index, :integer
    attribute :height, :string
    attribute :valign, :string
    attribute :mathsize, :string
    attribute :fontsize, :string
    attribute :fontstyle, :string
    attribute :mathcolor, :string
    attribute :fontfamily, :string
    attribute :fontweight, :string
    attribute :background, :string
    attribute :mathvariant, :string
    attribute :mathbackground, :string

    xml do
      root "mglyph"

      map_attribute "src", to: :src, namespace: nil
      map_attribute "alt", to: :alt, namespace: nil
      map_attribute "color", to: :color, namespace: nil
      map_attribute "index", to: :index, namespace: nil
      map_attribute "width", to: :width, namespace: nil
      map_attribute "height", to: :height, namespace: nil
      map_attribute "valign", to: :valign, namespace: nil
      map_attribute "mathsize", to: :mathsize, namespace: nil
      map_attribute "fontsize", to: :fontsize, namespace: nil
      map_attribute "fontstyle", to: :fontstyle, namespace: nil
      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "background", to: :background, namespace: nil
      map_attribute "fontfamily", to: :fontfamily, namespace: nil
      map_attribute "fontweight", to: :fontweight, namespace: nil
      map_attribute "mathvariant", to: :mathvariant, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil
    end
  end
end
