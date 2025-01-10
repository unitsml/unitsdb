# frozen_string_literal: true

module Mml
  module Configuration
    SUPPORTED_TAGS = %w[
      mmultiscripts
      maligngroup
      malignmark
      munderover
      semantics
      mscarries
      mfraction
      mphantom
      menclose
      mlongdiv
      mpadded
      msubsup
      mscarry
      mfenced
      msgroup
      mglyph
      mstack
      munder
      mtable
      mstyle
      mspace
      msline
      merror
      msrow
      mfrac
      mover
      mroot
      mtext
      msqrt
      none
      mrow
      msub
      msup
      mi
      mo
      mn
      ms
    ].freeze

    module_function

    def config
      @config ||= {}
    end

    def config=(config)
      self.config.merge!(config)
    end

    def adapter
      Lutaml::Model::Config.xml_adapter
    end

    def adapter=(adapter)
      Lutaml::Model::Config.xml_adapter_type = adapter.downcase
    end

    def class_for(class_name)
      config[class_name]
    end
  end
end
