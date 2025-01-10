# -*- encoding: utf-8 -*-
# stub: mml 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "mml".freeze
  s.version = "1.0.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ribose Inc.".freeze]
  s.bindir = "exe".freeze
  s.date = "2024-12-20"
  s.description = "MathML parser and builder used in Plurimath.\n".freeze
  s.email = ["open.source@ribose.com".freeze]
  s.homepage = "https://github.com/plurimath/mml".freeze
  s.licenses = ["BSD-2-Clause".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0.0".freeze)
  s.rubygems_version = "3.3.27".freeze
  s.summary = "MathML parser by Plurimath.".freeze

  s.installed_by_version = "3.5.22".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<lutaml-model>.freeze, ["~> 0.3".freeze])
  s.add_runtime_dependency(%q<zeitwerk>.freeze, [">= 0".freeze])
end
