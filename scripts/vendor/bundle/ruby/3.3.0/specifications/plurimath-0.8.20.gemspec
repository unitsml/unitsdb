# -*- encoding: utf-8 -*-
# stub: plurimath 0.8.20 ruby lib

Gem::Specification.new do |s|
  s.name = "plurimath".freeze
  s.version = "0.8.20".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "https://github.com/plurimath/plurimath", "source_code_uri" => "https://github.com/plurimath/plurimath" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ribose Inc.".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-01-06"
  s.description = "Converts LaTeX math into MathML.".freeze
  s.email = ["open.source@ribose.com".freeze]
  s.executables = ["plurimath".freeze]
  s.files = ["exe/plurimath".freeze]
  s.homepage = "https://github.com/plurimath/plurimath".freeze
  s.licenses = ["BSD-2-Clause".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.3.27".freeze
  s.summary = "Converts LaTeX math into MathML.".freeze

  s.installed_by_version = "3.5.22".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<ox>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<mml>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<thor>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<parslet>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<bigdecimal>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<lutaml-model>.freeze, [">= 0".freeze])
end
