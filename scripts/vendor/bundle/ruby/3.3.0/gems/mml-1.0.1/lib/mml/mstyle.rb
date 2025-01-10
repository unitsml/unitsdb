# frozen_string_literal: true

module Mml
  # rubocop:disable Metrics/ClassLength
  class Mstyle < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:mstyle)

    attribute :mathcolor, :string
    attribute :mathbackground, :string
    attribute :scriptlevel, :integer
    attribute :displaystyle, :string
    attribute :scriptsizemultiplier, :integer
    attribute :scriptminsize, :string
    attribute :infixlinebreakstyle, :string
    attribute :decimalpoint, :string
    attribute :accent, :string
    attribute :accentunder, :string
    attribute :align, :string
    attribute :alignmentscope, :string
    attribute :bevelled, :string
    attribute :charalign, :string
    attribute :charspacing, :string
    attribute :close, :string
    attribute :columnalign, :string
    attribute :columnlines, :string
    attribute :columnspacing, :string
    attribute :columnspan, :integer
    attribute :columnwidth, :string
    attribute :crossout, :string
    attribute :denomalign, :string
    attribute :depth, :string
    attribute :dir, :string
    attribute :edge, :string
    attribute :equalcolumns, :string
    attribute :equalrows, :string
    attribute :fence, :string
    attribute :form, :string
    attribute :frame, :string
    attribute :framespacing, :string
    attribute :groupalign, :string
    attribute :height, :string
    attribute :indentalign, :string
    attribute :indentalignfirst, :string
    attribute :indentalignlast, :string
    attribute :indentshift, :string
    attribute :indentshiftfirst, :string
    attribute :indentshiftlast, :string
    attribute :indenttarget, :string
    attribute :largeop, :string
    attribute :leftoverhang, :string
    attribute :length, :integer
    attribute :linebreak, :string
    attribute :linebreakmultchar, :string
    attribute :linebreakstyle, :string
    attribute :lineleading, :string
    attribute :linethickness, :string
    attribute :location, :string
    attribute :longdivstyle, :string
    attribute :lquote, :string
    attribute :lspace, :string
    attribute :mathsize, :string
    attribute :mathvariant, :string
    attribute :maxsize, :string
    attribute :minlabelspacing, :string
    attribute :minsize, :string
    attribute :movablelimits, :string
    attribute :mslinethickness, :string
    attribute :notation, :string
    attribute :numalign, :string
    attribute :open, :string
    attribute :position, :integer
    attribute :rightoverhang, :string
    attribute :rowalign, :string
    attribute :rowlines, :string
    attribute :rowspacing, :string
    attribute :rowspan, :integer
    attribute :rquote, :string
    attribute :rspace, :string
    attribute :selection, :integer
    attribute :separator, :string
    attribute :separators, :string
    attribute :shift, :integer
    attribute :side, :string
    attribute :stackalign, :string
    attribute :stretchy, :string
    attribute :subscriptshift, :string
    attribute :superscriptshift, :string
    attribute :symmetric, :string
    attribute :valign, :string
    attribute :width, :string
    attribute :fontfamily, :string
    attribute :fontweight, :string
    attribute :fontstyle, :string
    attribute :fontsize, :string
    attribute :color, :string
    attribute :background, :string
    attribute :veryverythinmathspace, :string
    attribute :verythinmathspace, :string
    attribute :thinmathspace, :string
    attribute :mediummathspace, :string
    attribute :thickmathspace, :string
    attribute :verythickmathspace, :string
    attribute :veryverythickmathspace, :string
    Mml::Configuration::SUPPORTED_TAGS.each do |tag|
      attribute :"#{tag}_value", Mml.const_get(tag.capitalize), collection: true
    end

    # rubocop:disable Metrics/BlockLength
    xml do
      root "mstyle", mixed: true

      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "scriptlevel", to: :scriptlevel, namespace: nil
      map_attribute "displaystyle", to: :displaystyle, namespace: nil
      map_attribute "scriptsizemultiplier", to: :scriptsizemultiplier, namespace: nil
      map_attribute "scriptminsize", to: :scriptminsize, namespace: nil
      map_attribute "infixlinebreakstyle", to: :infixlinebreakstyle, namespace: nil
      map_attribute "decimalpoint", to: :decimalpoint, namespace: nil
      map_attribute "accent", to: :accent, namespace: nil
      map_attribute "accentunder", to: :accentunder, namespace: nil
      map_attribute "align", to: :align, namespace: nil
      map_attribute "alignmentscope", to: :alignmentscope, namespace: nil
      map_attribute "bevelled", to: :bevelled, namespace: nil
      map_attribute "charalign", to: :charalign, namespace: nil
      map_attribute "charspacing", to: :charspacing, namespace: nil
      map_attribute "close", to: :close, namespace: nil
      map_attribute "columnalign", to: :columnalign, namespace: nil
      map_attribute "columnlines", to: :columnlines, namespace: nil
      map_attribute "columnspacing", to: :columnspacing, namespace: nil
      map_attribute "columnspan", to: :columnspan, namespace: nil
      map_attribute "columnwidth", to: :columnwidth, namespace: nil
      map_attribute "crossout", to: :crossout, namespace: nil
      map_attribute "denomalign", to: :denomalign, namespace: nil
      map_attribute "depth", to: :depth, namespace: nil
      map_attribute "dir", to: :dir, namespace: nil
      map_attribute "edge", to: :edge, namespace: nil
      map_attribute "equalcolumns", to: :equalcolumns, namespace: nil
      map_attribute "equalrows", to: :equalrows, namespace: nil
      map_attribute "fence", to: :fence, namespace: nil
      map_attribute "form", to: :form, namespace: nil
      map_attribute "frame", to: :frame, namespace: nil
      map_attribute "framespacing", to: :framespacing, namespace: nil
      map_attribute "groupalign", to: :groupalign, namespace: nil
      map_attribute "height", to: :height, namespace: nil
      map_attribute "indentalign", to: :indentalign, namespace: nil
      map_attribute "indentalignfirst", to: :indentalignfirst, namespace: nil
      map_attribute "indentalignlast", to: :indentalignlast, namespace: nil
      map_attribute "indentshift", to: :indentshift, namespace: nil
      map_attribute "indentshiftfirst", to: :indentshiftfirst, namespace: nil
      map_attribute "indentshiftlast", to: :indentshiftlast, namespace: nil
      map_attribute "indenttarget", to: :indenttarget, namespace: nil
      map_attribute "largeop", to: :largeop, namespace: nil
      map_attribute "leftoverhang", to: :leftoverhang, namespace: nil
      map_attribute "length", to: :length, namespace: nil
      map_attribute "linebreak", to: :linebreak, namespace: nil
      map_attribute "linebreakmultchar", to: :linebreakmultchar, namespace: nil
      map_attribute "linebreakstyle", to: :linebreakstyle, namespace: nil
      map_attribute "lineleading", to: :lineleading, namespace: nil
      map_attribute "linethickness", to: :linethickness, namespace: nil
      map_attribute "location", to: :location, namespace: nil
      map_attribute "longdivstyle", to: :longdivstyle, namespace: nil
      map_attribute "lquote", to: :lquote, namespace: nil
      map_attribute "lspace", to: :lspace, namespace: nil
      map_attribute "mathsize", to: :mathsize, namespace: nil
      map_attribute "mathvariant", to: :mathvariant, namespace: nil
      map_attribute "maxsize", to: :maxsize, namespace: nil
      map_attribute "minlabelspacing", to: :minlabelspacing, namespace: nil
      map_attribute "minsize", to: :minsize, namespace: nil
      map_attribute "movablelimits", to: :movablelimits, namespace: nil
      map_attribute "mslinethickness", to: :mslinethickness, namespace: nil
      map_attribute "notation", to: :notation, namespace: nil
      map_attribute "numalign", to: :numalign, namespace: nil
      map_attribute "open", to: :open, namespace: nil
      map_attribute "position", to: :position, namespace: nil
      map_attribute "rightoverhang", to: :rightoverhang, namespace: nil
      map_attribute "rowalign", to: :rowalign, namespace: nil
      map_attribute "rowlines", to: :rowlines, namespace: nil
      map_attribute "rowspacing", to: :rowspacing, namespace: nil
      map_attribute "rowspan", to: :rowspan, namespace: nil
      map_attribute "rquote", to: :rquote, namespace: nil
      map_attribute "rspace", to: :rspace, namespace: nil
      map_attribute "selection", to: :selection, namespace: nil
      map_attribute "separator", to: :separator, namespace: nil
      map_attribute "separators", to: :separators, namespace: nil
      map_attribute "shift", to: :shift, namespace: nil
      map_attribute "side", to: :side, namespace: nil
      map_attribute "stackalign", to: :stackalign, namespace: nil
      map_attribute "stretchy", to: :stretchy, namespace: nil
      map_attribute "subscriptshift", to: :subscriptshift, namespace: nil
      map_attribute "superscriptshift", to: :superscriptshift, namespace: nil
      map_attribute "symmetric", to: :symmetric, namespace: nil
      map_attribute "valign", to: :valign, namespace: nil
      map_attribute "width", to: :width, namespace: nil
      map_attribute "fontfamily", to: :fontfamily, namespace: nil
      map_attribute "fontweight", to: :fontweight, namespace: nil
      map_attribute "fontstyle", to: :fontstyle, namespace: nil
      map_attribute "fontsize", to: :fontsize, namespace: nil
      map_attribute "color", to: :color, namespace: nil
      map_attribute "background", to: :background, namespace: nil
      map_attribute "veryverythinmathspace", to: :veryverythinmathspace, namespace: nil
      map_attribute "verythinmathspace", to: :verythinmathspace, namespace: nil
      map_attribute "thinmathspace", to: :thinmathspace, namespace: nil
      map_attribute "mediummathspace", to: :mediummathspace, namespace: nil
      map_attribute "thickmathspace", to: :thickmathspace, namespace: nil
      map_attribute "verythickmathspace", to: :verythickmathspace, namespace: nil
      map_attribute "veryverythickmathspace", to: :veryverythickmathspace, namespace: nil
      Mml::Configuration::SUPPORTED_TAGS.each do |tag|
        map_element tag.to_sym, to: :"#{tag}_value"
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
  # rubocop:enable Metrics/ClassLength
end
