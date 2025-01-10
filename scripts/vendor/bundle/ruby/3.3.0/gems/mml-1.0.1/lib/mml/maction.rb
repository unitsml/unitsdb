# frozen_string_literal: true

module Mml
  class Maction < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:maction)

    attribute :mathcolor, :string
    attribute :mathbackground, :string
    attribute :actiontype, :string
    attribute :selection, :string

    xml do
      root "maction"

      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "actiontype", to: :actiontype, namespace: nil
      map_attribute "selection", to: :selection, namespace: nil
    end
  end
end
