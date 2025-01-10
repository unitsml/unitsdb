# -*- encoding: utf-8 -*-
# stub: ox 2.14.19 ruby lib ext
# stub: ext/ox/extconf.rb

Gem::Specification.new do |s|
  s.name = "ox".freeze
  s.version = "2.14.19".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/ohler55/ox/issues", "changelog_uri" => "https://github.com/ohler55/ox/blob/master/CHANGELOG.md", "documentation_uri" => "http://www.ohler.com/ox/doc/index.html", "homepage_uri" => "http://www.ohler.com/ox/", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/ohler55/ox" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze, "ext".freeze]
  s.authors = ["Peter Ohler".freeze]
  s.date = "2024-12-25"
  s.description = "A fast XML parser and object serializer that uses only standard C lib.\n\nOptimized XML (Ox), as the name implies was written to provide speed optimized\nXML handling. It was designed to be an alternative to Nokogiri and other Ruby\nXML parsers for generic XML parsing and as an alternative to Marshal for Object\nserialization. ".freeze
  s.email = "peter@ohler.com".freeze
  s.extensions = ["ext/ox/extconf.rb".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "CHANGELOG.md".freeze]
  s.files = ["CHANGELOG.md".freeze, "README.md".freeze, "ext/ox/extconf.rb".freeze]
  s.homepage = "http://www.ohler.com/ox".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze, "--title".freeze, "Ox".freeze, "--exclude".freeze, "extconf.rb".freeze, "lib".freeze, "ext/ox".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.5.11".freeze
  s.summary = "A fast XML parser and object serializer.".freeze

  s.installed_by_version = "3.5.22".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<bigdecimal>.freeze, [">= 3.0".freeze])
end
