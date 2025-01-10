require "lutaml/model"
require_relative "person"

class Address < Lutaml::Model::Serializable
  attribute :country, Lutaml::Model::Type::String
  attribute :post_code, Lutaml::Model::Type::String
  attribute :person, Person, collection: true

  json do
    map "country", to: :country
    map "postCode", to: :post_code
    map "person", to: :person
  end

  xml do
    root "Address"
    map_element "Country", to: :country
    map_element "PostCode", to: :post_code
    map_element "Person", to: :person
  end

  yaml do
    map "country", to: :country
    map "postCode", to: :post_code
    map "person", to: :person
  end

  toml do
    map "country", to: :country
    map "post_code", to: :post_code
    map "person", to: :person
  end
end
