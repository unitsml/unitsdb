require "spec_helper"
require "lutaml/model"

module EnumSpec
  class WithEnum < Lutaml::Model::Serializable
    attribute :without_enum, :string
    attribute :single_value, :string, values: %w[user admin super_admin]
    attribute :multi_value, :string, values: %w[singular dual plural], collection: true
  end
end

RSpec.describe "Enum" do
  let(:single_value_attr) do
    EnumSpec::WithEnum.attributes[:single_value]
  end

  let(:multi_value_attr) do
    EnumSpec::WithEnum.attributes[:multi_value]
  end

  let(:without_enum_attr) do
    EnumSpec::WithEnum.attributes[:without_enum]
  end

  let(:object) do
    EnumSpec::WithEnum.new
  end

  context "when values are provided for an attribute" do
    it "is marked as enum for single_value" do
      expect(single_value_attr.enum?).to be(true)
    end

    it "is marked as enum for multi_value" do
      expect(multi_value_attr.enum?).to be(true)
    end

    context "with enum convinience methods" do
      describe "#single_value" do
        it "returns single value" do
          expect { object.single_value = "user" }
            .to change(object, :single_value)
            .from(nil)
            .to("user")
        end
      end

      describe "#multi_value" do
        it "returns single value in array" do
          expect { object.multi_value = "dual" }
            .to change(object, :multi_value)
            .from([])
            .to(["dual"])
        end

        it "returns multiple value in array" do
          expect { object.multi_value = %w[dual plural] }
            .to change(object, :multi_value)
            .from([])
            .to(%w[dual plural])
        end
      end

      EnumSpec::WithEnum.enums.each_value do |enum_attr|
        enum_attr.enum_values.each do |value|
          describe "##{value}=" do
            it "sets the #{value} if true" do
              expect { object.public_send(:"#{value}=", true) }
                .to change { object.public_send(:"#{value}?") }
                .from(false)
                .to(true)
            end

            it "unsets the #{value} if false" do
              object.public_send(:"#{value}=", true)

              expect { object.public_send(:"#{value}=", false) }
                .to change(object, "#{value}?")
                .from(true)
                .to(false)
            end
          end

          describe "##{value}!" do
            it "method #{value}? should be present" do
              expect(object.respond_to?(:"#{value}!")).to be(true)
            end

            it "sets #{value} to true for enum" do
              expect { object.public_send(:"#{value}!") }
                .to change(object, "#{value}?")
                .from(false)
                .to(true)
            end
          end

          describe "##{value}?" do
            it "method #{value}? should be present" do
              expect(object.respond_to?(:"#{value}?")).to be(true)
            end

            it "is false if role is not #{value}" do
              expect(object.public_send(:"#{value}?")).to be(false)
            end

            it "is true if role is set to #{value}" do
              expect { object.public_send(:"#{value}=", value) }
                .to change(object, "#{value}?")
                .from(false)
                .to(true)
            end
          end

          it "adds a method named #{value}=" do
            expect(object.respond_to?(:"#{value}?")).to be(true)
          end

          it "adds a method named #{value}!" do
            expect(object.respond_to?(:"#{value}!")).to be(true)
          end
        end
      end
    end
  end

  context "when values are not provided for an attribute" do
    it "is not marked as enum" do
      expect(without_enum_attr.enum?).to be(false)
    end
  end
end
