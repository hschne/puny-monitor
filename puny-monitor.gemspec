# frozen_string_literal: true

require_relative "lib/puny_monitor/version"

Gem::Specification.new do |spec|
  spec.name = "puny-monitor"
  spec.version = PunyMonitor::VERSION
  spec.authors = ["Hans Schnedlitz"]
  spec.email = ["hello@hansschnedlitz.com"]

  spec.summary = "A batteries-included monitoring tool for single hosts. Works great with Kamal."
  spec.homepage = "https://github.com/hschne/puny-monitor"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hschne/puny-monitor"
  spec.metadata["changelog_uri"] = "https://github.com/hschne/puny-monitor/CHANGELOG"

  spec.files = Dir["{app,config,exe,lib,public}/**/*", "LICENSE", "README.md", "CHANGELOG.md"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_dependency("chartkick", "~> 5.1")
  spec.add_dependency("puma", ">= 6.6", "< 8.0")
  spec.add_dependency("rackup", "~> 2.1")
  spec.add_dependency("rufus-scheduler", "~> 3.9")
  spec.add_dependency("sinatra", "~> 4.0")
  spec.add_dependency("sinatra-activerecord", "~> 2.0")
  spec.add_dependency("sinatra-contrib", "~> 4.0")
  spec.add_dependency("sqlite3", "~> 2.0")
  spec.add_dependency("sys-filesystem", "~> 1.4")

  spec.metadata["rubygems_mfa_required"] = "true"
end
