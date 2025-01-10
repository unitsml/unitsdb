# frozen_string_literal: true

module Mml
  class Mtext < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:mtext)

    attribute :value, :string
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

    xml do
      root "mtext"

      map_content to: :value
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
    end
  end
end
