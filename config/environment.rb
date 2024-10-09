# frozen_string_literal: true

ENV["RACK_ENV"] ||= "development"

require "bundler/setup"
Bundler.require(:default, ENV.fetch("RACK_ENV", nil))

Dir["#{__dir__}/initializers/**/*.rb"].each { |file| require file }
Dir["#{__dir__}/../app/**/*.rb"].each { |file| require file }
