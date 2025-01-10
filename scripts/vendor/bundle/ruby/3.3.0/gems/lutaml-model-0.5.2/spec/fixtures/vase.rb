require "lutaml/model"

class Vase < Lutaml::Model::Serializable
  attribute :height, Lutaml::Model::Type::Float
  attribute :diameter, Lutaml::Model::Type::Float
  attribute :material, Lutaml::Model::Type::String
  attribute :manufacturer, Lutaml::Model::Type::String

  json do
    map "height", to: :height
    map "diameter", to: :diameter
    map "material", to: :material
    map "manufacturer", to: :manufacturer
  end

  yaml do
    map "height", to: :height
    map "diameter", to: :diameter
    map "material", to: :material
    map "manufacturer", to: :manufacturer
  end

  toml do
    map "height", to: :height
    map "diameter", to: :diameter
    map "material", to: :material
    map "manufacturer", to: :manufacturer
  end

  xml do
    root "vase"
    namespace "https://example.com/vase/1.0"
    map_element "height", to: :height
    map_element "diameter", to: :diameter
    map_element "material", to: :material
    map_attribute "manufacturer", to: :manufacturer
  end
end
