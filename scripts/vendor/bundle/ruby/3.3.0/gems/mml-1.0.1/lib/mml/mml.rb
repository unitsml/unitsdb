# frozen_string_literal: true

DEFAULT_ADAPTER = if RUBY_VERSION == "opal"
                    require "lutaml/model/xml_adapter/oga_adapter"
                    :oga
                  else
                    require "lutaml/model/xml_adapter/ox_adapter"
                    :ox
                  end

module Mml
  class Error < StandardError; end

  module_function

  def config
    Configuration.config
  end

  def parse(input, namespace_exist: true)
    Configuration.adapter = DEFAULT_ADAPTER unless Configuration.adapter

    if namespace_exist
      Mml::MathWithNamespace.from_xml(input)
    else
      Mml::MathWithNilNamespace.from_xml(input)
    end
  end
end
