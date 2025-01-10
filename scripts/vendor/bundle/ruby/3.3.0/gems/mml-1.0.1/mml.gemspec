# frozen_string_literal: true

require_relative "lib/mml/version"

Gem::Specification.new do |spec|
  spec.name = "mml"
  spec.version = Mml::VERSION
  spec.authors = ["Ribose Inc."]
  spec.email = ["open.source@ribose.com"]

  spec.summary = "MathML parser by Plurimath."
  spec.description = <<~DESCRIPTION
    MathML parser and builder used in Plurimath.
  DESCRIPTION

  spec.homepage = "https://github.com/plurimath/mml"
  spec.license = "BSD-2-Clause"

  spec.test_files = `git ls-files -- {spec}/*`.split("\n")
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lutaml-model", "~> 0.3"
  spec.add_runtime_dependency "zeitwerk"
end
