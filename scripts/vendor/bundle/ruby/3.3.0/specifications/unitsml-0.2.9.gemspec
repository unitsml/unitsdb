# -*- encoding: utf-8 -*-
# stub: unitsml 0.2.9 ruby lib unitsdb/**/*.yaml

Gem::Specification.new do |s|
  s.name = "unitsml".freeze
  s.version = "0.2.9".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "https://github.com/unitsml/unitsml-ruby" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze, "unitsdb/**/*.yaml".freeze]
  s.authors = ["Ribose Inc.".freeze]
  s.bindir = "exe".freeze
  s.date = "2024-12-16"
  s.description = "Gem-wrapper for working with unitsdb".freeze
  s.email = ["open.source@ribose.com".freeze]
  s.homepage = "https://github.com/unitsml/unitsml-ruby".freeze
  s.licenses = ["BSD-2-Clause".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.3.27".freeze
  s.summary = "Gem-wrapper for working with unitsdb".freeze

  s.installed_by_version = "3.5.22".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<htmlentities>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<plurimath>.freeze, ["~> 0.8.4".freeze])
  s.add_development_dependency(%q<byebug>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<equivalent-xml>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<pry>.freeze, ["~> 0.12.2".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 12.0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.6".freeze])
  s.add_development_dependency(%q<rubocop>.freeze, ["= 0.54.0".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.15".freeze])
end
