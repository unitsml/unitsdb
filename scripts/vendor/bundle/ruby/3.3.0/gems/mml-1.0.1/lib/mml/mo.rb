# frozen_string_literal: true

module Mml
  class Mo < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:mo)

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
    attribute :form, :string
    attribute :fence, :string
    attribute :separator, :string
    attribute :lspace, :string
    attribute :rspace, :string
    attribute :stretchy, :string
    attribute :symmetric, :string
    attribute :maxsize, :string
    attribute :minsize, :string
    attribute :largeop, :string
    attribute :movablelimits, :string
    attribute :accent, :string
    attribute :linebreak, :string
    attribute :lineleading, :string
    attribute :linebreakstyle, :string
    attribute :linebreakmultchar, :string
    attribute :indentalign, :string
    attribute :indentshift, :string
    attribute :indenttarget, :string
    attribute :indentalignfirst, :string
    attribute :indentshiftfirst, :string
    attribute :indentalignlast, :string
    attribute :indentshiftlast, :string

    # rubocop:disable Metrics/BlockLength
    xml do
      root "mo"

      map_content to: :value
      map_attribute "dir", to: :dir, namespace: nil
      map_attribute "form", to: :form, namespace: nil
      map_attribute "fence", to: :fence, namespace: nil
      map_attribute "color", to: :color, namespace: nil
      map_attribute "accent", to: :accent, namespace: nil
      map_attribute "lspace", to: :lspace, namespace: nil
      map_attribute "rspace", to: :rspace, namespace: nil
      map_attribute "maxsize", to: :maxsize, namespace: nil
      map_attribute "minsize", to: :minsize, namespace: nil
      map_attribute "largeop", to: :largeop, namespace: nil
      map_attribute "stretchy", to: :stretchy, namespace: nil
      map_attribute "mathsize", to: :mathsize, namespace: nil
      map_attribute "fontsize", to: :fontsize, namespace: nil
      map_attribute "linebreak", to: :linebreak, namespace: nil
      map_attribute "fontstyle", to: :fontstyle, namespace: nil
      map_attribute "separator", to: :separator, namespace: nil
      map_attribute "symmetric", to: :symmetric, namespace: nil
      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "fontfamily", to: :fontfamily, namespace: nil
      map_attribute "fontweight", to: :fontweight, namespace: nil
      map_attribute "background", to: :background, namespace: nil
      map_attribute "mathvariant", to: :mathvariant, namespace: nil
      map_attribute "lineleading", to: :lineleading, namespace: nil
      map_attribute "indentalign", to: :indentalign, namespace: nil
      map_attribute "indentshift", to: :indentshift, namespace: nil
      map_attribute "indenttarget", to: :indenttarget, namespace: nil
      map_attribute "movablelimits", to: :movablelimits, namespace: nil
      map_attribute "linebreakstyle", to: :linebreakstyle, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "indentalignlast", to: :indentalignlast, namespace: nil
      map_attribute "indentshiftlast", to: :indentshiftlast, namespace: nil
      map_attribute "indentalignfirst", to: :indentalignfirst, namespace: nil
      map_attribute "indentshiftfirst", to: :indentshiftfirst, namespace: nil
      map_attribute "linebreakmultchar", to: :linebreakmultchar, namespace: nil
    end
    # rubocop:enable Metrics/BlockLength
  end
end
