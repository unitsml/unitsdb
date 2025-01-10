# frozen_string_literal: true

module Mml
  class Mlabeledtr < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:mlabeledtr)

    attribute :mathbackground, :string
    attribute :columnalign, :string
    attribute :groupalign, :string
    attribute :mathcolor, :string
    attribute :rowalign, :string
    attribute :id, :string
    attribute :mtd_value, Mtd, collection: true

    xml do
      root "mlabeledtr", mixed: true

      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "columnalign", to: :columnalign, namespace: nil
      map_attribute "groupalign", to: :groupalign, namespace: nil
      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "rowalign", to: :rowalign, namespace: nil
      map_attribute "id", to: :id, namespace: nil
      map_element "mtd", to: :mtd_value
    end
  end
end
