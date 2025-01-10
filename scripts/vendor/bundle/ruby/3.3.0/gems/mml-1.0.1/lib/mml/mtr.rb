# frozen_string_literal: true

module Mml
  class Mtr < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:mtr)

    attribute :mathcolor, :string
    attribute :mathbackground, :string
    attribute :rowalign, :string
    attribute :columnalign, :string
    attribute :groupalign, :string
    attribute :mtd_value, Mtd, collection: true

    xml do
      root "mtr", mixed: true

      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "rowalign", to: :rowalign, namespace: nil
      map_attribute "columnalign", to: :columnalign, namespace: nil
      map_attribute "groupalign", to: :groupalign, namespace: nil
      map_element "mtd", to: :mtd_value
    end
  end
end
