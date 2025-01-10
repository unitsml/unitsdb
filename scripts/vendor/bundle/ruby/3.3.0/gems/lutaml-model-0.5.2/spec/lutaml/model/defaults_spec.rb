# frozen_string_literal: true

require "spec_helper"
require "lutaml/model"

module DefaultsSpec
  class GlazeTag < Lutaml::Model::Serializable
    attribute :text, :string, default: -> { "" }

    xml do
      root "Tag"
      map_content to: :text
    end
  end

  class Glaze < Lutaml::Model::Serializable
    attribute :name, :string, default: -> { "Standard Glaze" }
    attribute :color, :string, default: -> { "Clear" }
    attribute :opacity, :string, default: -> { "Opaque" }
    attribute :temperature, :integer, default: -> { 1050 }
    attribute :firing_time, :integer, default: -> { 60 }
    attribute :balance, "Decimal", default: -> { BigDecimal("0.0") }
    attribute :tags, GlazeTag, collection: true
    attribute :properties, :hash, default: -> { { food_safe: true } }
    attribute :status, :string, default: -> { "active" }
    attribute :batch_number, :integer, default: -> { 0 }
    attribute :manufacturer, :string, default: -> { "example@glazes.com" }
    attribute :type, :string, values: %w[earthenware stoneware porcelain], default: -> {
      "stoneware"
    }

    xml do
      root "Glaze"
      map_element "Name", to: :name
      map_element "Color", to: :color
      map_element "Opacity", to: :opacity, render_default: true
      map_element "Temperature", to: :temperature
      map_element "FiringTime", to: :firing_time, render_default: true
      map_element "Balance", to: :balance
      map_element "Tags", to: :tags
      map_element "Properties", to: :properties
      map_element "Status", to: :status
      map_element "BatchNumber", to: :batch_number
      map_element "Manufacturer", to: :manufacturer
      map_element "Type", to: :type
    end

    json do
      map "name", to: :name
      map "color", to: :color
      map "opacity", to: :opacity, render_default: true
      map "temperature", to: :temperature
      map "firingTime", to: :firing_time, render_default: true
      map "balance", to: :balance
      map "tags", to: :tags
      map "properties", to: :properties
      map "status", to: :status
      map "batchNumber", to: :batch_number
      map "manufacturer", to: :manufacturer
      map "type", to: :type
    end

    yaml do
      map "name", to: :name
      map "color", to: :color
    end
  end

  # Class for testing default values without render_default option
  class BasicGlaze < Lutaml::Model::Serializable
    attribute :name, :string, default: -> { "Basic Glaze" }
    attribute :temperature, :integer, default: -> { 1050 }
    attribute :opacity, :string, default: -> { "Opaque" }

    xml do
      root "BasicGlaze"
      map_element "name", to: :name
      map_element "temperature", to: :temperature
      map_element "opacity", to: :opacity
    end

    json do
      map "name", to: :name
      map "temperature", to: :temperature
      map "opacity", to: :opacity
    end
  end

  # Class for testing explicit render_default: false
  class NoDefaultGlaze < Lutaml::Model::Serializable
    attribute :name, :string, default: -> { "No Default Glaze" }
    attribute :temperature, :integer, default: -> { 1050 }
    attribute :opacity, :string, default: -> { "Opaque" }

    xml do
      root "NoDefaultGlaze"
      map_element "name", to: :name, render_default: false
      map_element "temperature", to: :temperature, render_default: false
      map_element "opacity", to: :opacity, render_default: false
    end

    json do
      map "name", to: :name, render_default: false
      map "temperature", to: :temperature, render_default: false
      map "opacity", to: :opacity, render_default: false
    end
  end

  # Class for testing render_default: true with custom model
  class Lang
    attr_accessor :lang, :content
  end

  class CustomModelWithDefaultValue < Lutaml::Model::Serializable
    model Lang

    attribute :lang, :string, default: -> { "en" }
    attribute :content, :string, default: -> { "default value not render when render_default is false" }

    xml do
      root "CustomModelWithDefaultValue"
      map_attribute "lang", to: :lang, render_default: true
      map_content to: :content, render_default: false
    end

    key_value do
      map "lang", to: :lang, render_default: true
      map "content", to: :content, render_default: false
    end
  end
end

RSpec.describe DefaultsSpec::Glaze do
  describe "Default value initialization" do
    subject(:default_model) { described_class.new }

    it "initializes with correct default values" do
      expect(default_model.name).to eq("Standard Glaze")
      expect(default_model.color).to eq("Clear")
      expect(default_model.opacity).to eq("Opaque")
      expect(default_model.temperature).to eq(1050)
      expect(default_model.firing_time).to eq(60)
      expect(default_model.balance).to eq(BigDecimal("0.0"))
      expect(default_model.tags).to eq([])
      expect(default_model.properties).to eq({ food_safe: true })
      expect(default_model.status).to eq("active")
      expect(default_model.batch_number).to eq(0)
      expect(default_model.manufacturer).to eq("example@glazes.com")
      expect(default_model.type).to eq("stoneware")
    end

    it "contains the default value in instance" do
      instance = DefaultsSpec::CustomModelWithDefaultValue.new

      expect(instance.content).to eq("default value not render when render_default is false")
      expect(instance.lang).to eq("en")
    end
  end

  describe "Default value rendering behavior" do
    context "with XML serialization" do
      context "when value is default" do
        it "does not serialize when render_default is false" do
          glaze = DefaultsSpec::NoDefaultGlaze.new
          xml = glaze.to_xml

          expect(xml).not_to include("<name>")
          expect(xml).not_to include("<temperature>")
          expect(xml).not_to include("<opacity>")
        end

        it "does not serialize when render_default is not set" do
          glaze = DefaultsSpec::BasicGlaze.new
          xml = glaze.to_xml

          expect(xml).not_to include("<name>")
          expect(xml).not_to include("<temperature>")
          expect(xml).not_to include("<opacity>")
        end

        it "serializes when render_default is true" do
          glaze = described_class.new
          xml = glaze.to_xml

          expect(xml).to include("<Opacity>Opaque</Opacity>")
          expect(xml).to include("<FiringTime>60</FiringTime>")
        end

        it "serializes when render_default is true with custom model" do
          parsed = DefaultsSpec::CustomModelWithDefaultValue.from_xml "<CustomModelWithDefaultValue>English</CustomModelWithDefaultValue>"
          expect(parsed.lang).to eq("en")
          expect(parsed.content).to eq("English")

          serialized = DefaultsSpec::CustomModelWithDefaultValue.to_xml(parsed)
          expect(serialized).to eq("<CustomModelWithDefaultValue lang=\"en\">English</CustomModelWithDefaultValue>")
        end
      end

      context "when value is not default" do
        it "serializes regardless of render_default setting" do
          glaze = DefaultsSpec::NoDefaultGlaze.new(
            name: "Custom Glaze",
            temperature: 1200,
            opacity: "Translucent",
          )
          xml = glaze.to_xml

          expect(xml).to include("<name>Custom Glaze</name>")
          expect(xml).to include("<temperature>1200</temperature>")
          expect(xml).to include("<opacity>Translucent</opacity>")
        end
      end
    end

    context "with JSON serialization" do
      context "when value is default" do
        it "does not serialize when render_default is false" do
          glaze = DefaultsSpec::NoDefaultGlaze.new
          json = JSON.parse(glaze.to_json)

          expect(json).not_to have_key("name")
          expect(json).not_to have_key("temperature")
          expect(json).not_to have_key("opacity")
        end

        it "does not serialize when render_default is not set" do
          glaze = DefaultsSpec::BasicGlaze.new
          json = JSON.parse(glaze.to_json)

          expect(json).not_to have_key("name")
          expect(json).not_to have_key("temperature")
          expect(json).not_to have_key("opacity")
        end

        it "serializes when render_default is true" do
          glaze = described_class.new
          json = JSON.parse(glaze.to_json)

          expect(json["opacity"]).to eq("Opaque")
          expect(json["firingTime"]).to eq(60)
        end

        it "serializes when render_default is true with custom model" do
          parsed = DefaultsSpec::CustomModelWithDefaultValue.from_json('{"content": "content"}')
          expect(parsed.lang).to eq("en")
          expect(parsed.content).to eq("content")

          serialized = DefaultsSpec::CustomModelWithDefaultValue.to_json(parsed)
          expect(serialized).to eq('{"lang":"en","content":"content"}')
        end
      end

      context "when value is not default" do
        it "serializes regardless of render_default setting" do
          glaze = DefaultsSpec::NoDefaultGlaze.new(
            name: "Custom Glaze",
            temperature: 1200,
            opacity: "Translucent",
          )
          json = JSON.parse(glaze.to_json)

          expect(json["name"]).to eq("Custom Glaze")
          expect(json["temperature"]).to eq(1200)
          expect(json["opacity"]).to eq("Translucent")
        end
      end
    end

    context "with YAML serialization" do
      context "when value is default" do
        it "serializes when render_default is true with custom model" do
          parsed = DefaultsSpec::CustomModelWithDefaultValue.from_yaml("---\ncontent: content")
          expect(parsed.lang).to eq("en")
          expect(parsed.content).to eq("content")

          serialized = DefaultsSpec::CustomModelWithDefaultValue.to_yaml(parsed)
          expect(serialized).to eq("---\nlang: en\ncontent: content\n")
        end
      end
    end

    context "with TOML serialization" do
      context "when value is default" do
        it "serializes when render_default is true with custom model" do
          parsed = DefaultsSpec::CustomModelWithDefaultValue.from_toml("content = 'content'")
          expect(parsed.lang).to eq("en")
          expect(parsed.content).to eq("content")

          serialized = DefaultsSpec::CustomModelWithDefaultValue.to_toml(parsed)
          expect(serialized).to eq("content = \"content\"\nlang = \"en\"\n")
        end
      end
    end
  end
end
