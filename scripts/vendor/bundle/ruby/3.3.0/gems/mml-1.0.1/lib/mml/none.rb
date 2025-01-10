# frozen_string_literal: true

module Mml
  class None < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:none)

    attribute :mathcolor, :string
    attribute :mathbackground, :string

    xml do
      root "none"

      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil
    end
  end
end
