# frozen_string_literal: true

ENV["RACK_ENV"] ||= "development"

require "bundler/setup"
Bundler.require(:default, ENV.fetch("RACK_ENV", nil))

# Require in all files in 'app' directory
require_relative "../app/puny_monitor"
