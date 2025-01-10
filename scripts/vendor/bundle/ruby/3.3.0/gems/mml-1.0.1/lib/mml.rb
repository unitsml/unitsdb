# frozen_string_literal: true

require "zeitwerk"
require "lutaml/model"
require_relative "mml/mml"

loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.ignore("#{__dir__}/lib/mml.rb")
loader.setup
