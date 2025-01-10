require_relative "serialize"

module Lutaml
  module Model
    class Serializable
      include Serialize
    end
  end
end

require_relative "comparable_nil"
