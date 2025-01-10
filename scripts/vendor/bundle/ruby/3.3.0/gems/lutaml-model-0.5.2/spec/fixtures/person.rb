require "lutaml/model"

class Person < Lutaml::Model::Serializable
  attribute :first_name, Lutaml::Model::Type::String
  attribute :last_name, Lutaml::Model::Type::String
  attribute :age, Lutaml::Model::Type::Integer
  attribute :height, Lutaml::Model::Type::Float
  attribute :birthdate, Lutaml::Model::Type::Date
  attribute :last_login, Lutaml::Model::Type::DateTime
  attribute :wakeup_time, Lutaml::Model::Type::TimeWithoutDate
  attribute :active, Lutaml::Model::Type::Boolean

  xml do
    root "Person"
    namespace "http://example.com/person", "p"

    map_element "FirstName",
                to: :first_name,
                namespace: "http://example.com/nsp1",
                prefix: "nsp1"
    map_element "LastName",
                to: :last_name,
                namespace: "http://example.com/nsp1",
                prefix: "nsp1"
    map_element "Age", to: :age
    map_element "Height", to: :height
    map_element "Birthdate", to: :birthdate
    map_element "LastLogin", to: :last_login
    map_element "WakeupTime", to: :wakeup_time
    map_element "Active", to: :active
  end

  json do
    map "firstName", to: :first_name
    map "lastName", to: :last_name
    map "age", to: :age
    map "height", to: :height
    map "birthdate", to: :birthdate
    map "lastLogin", to: :last_login
    map "wakeupTime", to: :wakeup_time
    map "active", to: :active
  end

  yaml do
    map "firstName", to: :first_name
    map "lastName", with: { to: :yaml_from_last_name, from: :yaml_to_last_name }
    map "age", to: :age
    map "height", to: :height
    map "birthdate", to: :birthdate
    map "lastLogin", to: :last_login
    map "wakeupTime", to: :wakeup_time
    map "active", to: :active
  end

  toml do
    map "first_name", to: :first_name
    map "last_name", to: :last_name
    map "age", to: :age
    map "height", to: :height
    map "birthdate", to: :birthdate
    map "last_login", to: :last_login
    map "wakeup_time", to: :wakeup_time
    map "active", to: :active
  end

  def yaml_from_last_name(model, doc)
    doc["lastName"] = model.last_name
  end

  def yaml_to_last_name(model, value)
    model.last_name = value
  end
end
