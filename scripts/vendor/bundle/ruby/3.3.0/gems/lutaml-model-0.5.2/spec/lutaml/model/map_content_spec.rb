require "spec_helper"
require "lutaml/model"

# module MapContent
#   class Italic < Lutaml::Model::Serializable
#     attribute :text, Lutaml::Model::Type::String

#     xml do
#       root "italic"
#       map_content to: :text
#     end
#   end

#   class Bold < Lutaml::Model::Serializable
#     attribute :text, Lutaml::Model::Type::String
#     attribute :italic, Italic

#     xml do
#       root "b"
#       mixed do
#         map_content to: :text
#         map "italic", to: :italic
#       end
#     end
#   end

#   class RichText < Lutaml::Model::Serializable
#     attribute :text, Lutaml::Model::Type::String
#     attribute :bold, Bold
#     attribute :italic, Italic

#     xml do
#       mixed do
#         map_content to: :text
#         map_element "bold", to: :bold
#         map_element "italic", to: :italic
#       end
#     end
#   end

#   class Car < Lutaml::Model::Serializable
#     attribute :description, RichText
#     attribute :make, Lutaml::Model::Type::String

#     xml do
#       root "car"
#       map_element "description", to: :description
#       map_element "make", to: :make
#     end
#   end
# end

# RSpec.xdescribe MapContent do
#   let(:italic_text) { MapContent::Italic.new(text: "italic text") }
#   let(:bold_text) do
#     MapContent::Bold.new(
#       text: "bold text",
#       italic: italic_text,
#     )
#   end
#   let(:rich_text) do
#     MapContent::RichText.new(
#       text: "regular text",
#       bold: bold_text,
#       italic: italic_text,
#     )
#   end
#   let(:attributes) { { description: rich_text, make: "Toyota" } }
#   let(:model) { MapContent::Car.new(attributes) }

#   let(:model_xml) {
#     <<~XML
#       <car>
#         <description>
#           regular text
#           <bold>
#             bold text
#             <italic>italic text</italic>
#           </bold>
#           <italic>italic text</italic>
#         </description>
#         <make>Toyota</make>
#       </car>
#     XML
#   }

#   it "initializes with default values" do
#     default_model = Car.new
#     expect(default_model.description).to eq(nil)
#     expect(default_model.make).to eq(nil)
#   end

#   it "serializes to XML" do
#     expected_xml = model_xml.strip
#     expect(model.to_xml.strip).to eq(expected_xml)
#   end

#   it "deserializes from XML" do
#     sample = Car.from_xml(model_xml)
#     expect(sample.description.text).to eq("regular text")
#     expect(sample.description.bold.text).to eq("bold text")
#     expect(sample.description.bold.italic.text).to eq("italic text")
#     expect(sample.description.italic.text).to eq("italic text")
#     expect(sample.make).to eq("Toyota")
#   end

#   it "round-trips XML" do
#     xml = model.to_xml
#     new_model = Car.from_xml(xml)
#     expect(new_model.description.text).to eq(model.description.text)
#     expect(new_model.description.bold.text).to eq(model.description.bold.text)
#     expect(new_model.description.bold.italic.text)
#       .to eq(model.description.bold.italic.text)
#     expect(new_model.description.italic.text)
#       .to eq(model.description.italic.text)
#     expect(new_model.make).to eq(model.make)
#   end
# end
