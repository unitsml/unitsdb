module Lutaml
  module Model
    class TypeError < Error
      def initialize(message)
        super("Type Error: #{message}")
      end
    end
  end
end
