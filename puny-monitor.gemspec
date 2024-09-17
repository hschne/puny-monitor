# frozen_string_literal: true

require_relative "lib/puny_monitor/version"

Gem::Specification.new do |spec|
  spec.name = "puny-monitor"
  spec.version = PunyMonitor::VERSION
  spec.authors = ["hschne"]
  spec.email = ["hans.schnedlitz@gmail.com"]

  spec.summary = "A batteries-included monitoring tool for single hosts. Works great with Kamal."
  spec.homepage = "https://github.com/hschne/puny-monitor"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hschne/puny-monitor"
  spec.metadata["changelog_uri"] = "https://github.com/hschne/puny-monitor/CHANGELOG"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.metadata["rubygems_mfa_required"] = "true"
end
