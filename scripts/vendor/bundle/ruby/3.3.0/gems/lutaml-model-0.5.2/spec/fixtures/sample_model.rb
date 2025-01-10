require "lutaml/model"

class SampleModelTag < Lutaml::Model::Serializable
  attribute :text, :string, default: -> { "" }

  xml do
    root "Tag"
    map_content to: :text
  end
end

class SampleModel < Lutaml::Model::Serializable
  attribute :name, :string, default: -> { "Anonymous" }
  attribute :age, :integer, default: -> { 18 }
  attribute :balance, :decimal, default: -> { BigDecimal("0.0") }
  attribute :tags, SampleModelTag, collection: true
  attribute :preferences, :hash, default: -> { { notifications: true } }
  attribute :status, :string, default: -> { "active" }
  attribute :large_number, :integer, default: -> { 0 }
  attribute :email, :string, default: -> { "example@example.com" }
  attribute :role, :string, values: %w[user admin guest], default: -> { "user" }

  xml do
    root "SampleModel"
    map_element "Name", to: :name
    map_element "Age", to: :age
    map_element "Balance", to: :balance
    map_element "Tags", to: :tags
    map_element "Preferences", to: :preferences
    map_element "Status", to: :status
    map_element "LargeNumber", to: :large_number
    map_element "Email", to: :email
    map_element "Role", to: :role
  end

  yaml do
    map "name", to: :name
    map "age", to: :age
    map "balance", to: :balance
    map "tags", to: :tags
    map "preferences", to: :preferences
    map "status", to: :status
    map "large_number", to: :large_number
    map "email", to: :email
    map "role", to: :role
  end
end
