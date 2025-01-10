# frozen_string_literal: true

module Mml
  class Mspace < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:mspace)

    attribute :mathcolor, :string
    attribute :mathbackground, :string
    attribute :mathvariant, :string
    attribute :mathsize, :string
    attribute :dir, :string
    attribute :fontfamily, :string
    attribute :fontweight, :string
    attribute :fontstyle, :string
    attribute :fontsize, :string
    attribute :color, :string
    attribute :background, :string
    attribute :width, :string
    attribute :height, :string
    attribute :depth, :string
    attribute :linebreak, :string
    attribute :indentalign, :string
    attribute :indentshift, :string
    attribute :indenttarget, :string
    attribute :indentalignfirst, :string
    attribute :indentshiftfirst, :string
    attribute :indentalignlast, :string
    attribute :indentshiftlast, :string

    xml do
      root "mspace"

      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "mathvariant", to: :mathvariant, namespace: nil
      map_attribute "mathsize", to: :mathsize, namespace: nil
      map_attribute "dir", to: :dir, namespace: nil
      map_attribute "fontfamily", to: :fontfamily, namespace: nil
      map_attribute "fontweight", to: :fontweight, namespace: nil
      map_attribute "fontstyle", to: :fontstyle, namespace: nil
      map_attribute "fontsize", to: :fontsize, namespace: nil
      map_attribute "color", to: :color, namespace: nil
      map_attribute "background", to: :background, namespace: nil
      map_attribute "width", to: :width, namespace: nil
      map_attribute "height", to: :height, namespace: nil
      map_attribute "depth", to: :depth, namespace: nil
      map_attribute "linebreak", to: :linebreak, namespace: nil
      map_attribute "indentalign", to: :indentalign, namespace: nil
      map_attribute "indentshift", to: :indentshift, namespace: nil
      map_attribute "indenttarget", to: :indenttarget, namespace: nil
      map_attribute "indentalignfirst", to: :indentalignfirst, namespace: nil
      map_attribute "indentshiftfirst", to: :indentshiftfirst, namespace: nil
      map_attribute "indentalignlast", to: :indentalignlast, namespace: nil
      map_attribute "indentshiftlast", to: :indentshiftlast, namespace: nil
    end
  end
end
