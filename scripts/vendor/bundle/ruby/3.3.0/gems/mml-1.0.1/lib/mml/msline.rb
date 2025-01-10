# frozen_string_literal: true

module Mml
  class Msline < Lutaml::Model::Serializable
    model Mml::Configuration.class_for(:msline)

    attribute :mathcolor, :string
    attribute :mathbackground, :string
    attribute :position, :integer
    attribute :length, :integer
    attribute :leftoverhang, :string
    attribute :rightoverhang, :string
    attribute :mslinethickness, :string

    xml do
      root "msline"

      map_attribute "mathcolor", to: :mathcolor, namespace: nil
      map_attribute "mathbackground", to: :mathbackground, namespace: nil
      map_attribute "position", to: :position, namespace: nil
      map_attribute "length", to: :length, namespace: nil
      map_attribute "leftoverhang", to: :leftoverhang, namespace: nil
      map_attribute "rightoverhang", to: :rightoverhang, namespace: nil
      map_attribute "mslinethickness", to: :mslinethickness, namespace: nil
    end
  end
end
