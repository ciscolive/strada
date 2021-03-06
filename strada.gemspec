# frozen_string_literal: true

require_relative "lib/strada/version"
Gem::Specification.new do |s|
  s.name        = "strada"
  s.version     = Strada::VERSION
  s.licenses    = ["MIT"]
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["WENWU.YAN"]
  s.email       = "968826@gmail.com"
  s.homepage    = "http://github.com/ciscolive/strada"
  s.summary     = "configuration library"
  s.description = "configuration library with object access to YAML/JSON/TOML backends"

  s.required_ruby_version = ">= 2.6.0"
  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  s.metadata["homepage_uri"]    = s.homepage
  s.metadata["source_code_uri"] = "https://github.com/ciscolive/strada"
  s.metadata["changelog_uri"]   = "https://github.com/ciscolive/strada/blob/main/README.md"

  s.files        = `git ls-files`.split("\n")
  s.require_path = "lib"
end
