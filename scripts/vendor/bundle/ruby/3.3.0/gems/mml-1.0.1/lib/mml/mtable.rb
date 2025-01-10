# frozen_string_literal: true

module Mml
  class Mtable < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:mtable)

    attribute :mathcolor, :string
    attribute :mathbackground, :string
    attribute :align, :string
    attribute :rowalign, :string
    attribute :columnalign, :string
    attribute :groupalign, :string
    attribute :alignmentscope, :string
    attribute :columnwidth, :string
    attribute :width, :string
    attribute :rowspacing, :string
    attribute :columnspacing, :string
    attribute :rowlines, :string
    attribute :columnlines, :string
    attribute :frame, :string
    attribute :framespacing, :string
    attribute :equalrows, :string
    attribute :equalcolumns, :string
    attribute :displaystyle, :string
    attribute :side, :string
    attribute :minlabelspacing, :string
    attribute :mlabeledtr_value, Mlabeledtr, collection: true
    attribute :mtr_value, Mtr, collection: true

    xml do
      root "mtable", mixed: true

      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "align", to: :align, namespace: nil
      map_attribute "rowalign", to: :rowalign, namespace: nil
      map_attribute "columnalign", to: :columnalign, namespace: nil
      map_attribute "groupalign", to: :groupalign, namespace: nil
      map_attribute "alignmentscope", to: :alignmentscope, namespace: nil
      map_attribute "columnwidth", to: :columnwidth, namespace: nil
      map_attribute "width", to: :width, namespace: nil
      map_attribute "rowspacing", to: :rowspacing, namespace: nil
      map_attribute "columnspacing", to: :columnspacing, namespace: nil
      map_attribute "rowlines", to: :rowlines, namespace: nil
      map_attribute "columnlines", to: :columnlines, namespace: nil
      map_attribute "frame", to: :frame, namespace: nil
      map_attribute "framespacing", to: :framespacing, namespace: nil
      map_attribute "equalrows", to: :equalrows, namespace: nil
      map_attribute "equalcolumns", to: :equalcolumns, namespace: nil
      map_attribute "displaystyle", to: :displaystyle, namespace: nil
      map_attribute "side", to: :side, namespace: nil
      map_attribute "minlabelspacing", to: :minlabelspacing, namespace: nil
      map_element "mlabeledtr", to: :mlabeledtr_value
      map_element "mtr", to: :mtr_value
    end
  end
end
