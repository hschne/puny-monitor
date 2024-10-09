# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in puny-monitor.gemspec
gemspec

# Require only base
# See http://aaronlerch.github.io/blog/sinatra-bundler-and-the-global-namespace/
gem "sinatra", "~> 4.0", require: "sinatra/base"
gem "sinatra-contrib", "~> 4.0", require: false

# Database
gem "groupdate", "~> 6.4"
gem "sinatra-activerecord", "~> 2.0"
gem "sqlite3", "~> 2.0"

# Funcationality
gem "chartkick", "~> 5.1"
gem "rufus-scheduler", "~> 3.9"
gem "sys-filesystem", "~> 1.4"

gem "rackup", "~> 2.1"
gem "rake", "~> 13.0"

group :development do
  gem "debug", "~> 1.9"
  gem "erb-formatter", "~> 0.7.3"
  gem "foreman", "~> 0.88.1"
  gem "rubocop", "~> 1.21"
  gem "rubocop-minitest", "~> 0.34.5"
  gem "rubocop-rake", "~> 0.6.0"
end

group :test do
  gem "minitest", "~> 5.16"
end
