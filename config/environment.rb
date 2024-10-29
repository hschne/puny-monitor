# frozen_string_literal: true

ENV["RACK_ENV"] ||= "development"

require "bundler/setup"
Bundler.require(:default, ENV.fetch("RACK_ENV", nil))

require "sinatra/contrib"
require "sinatra/activerecord"
require "rufus-scheduler"
require "groupdate"
require "chartkick"
require "sqlite3"
require "sys-filesystem"

Dir["#{__dir__}/initializers/**/*.rb"].each { |file| require file }
Dir["#{__dir__}/../app/**/*.rb"].each { |file| require file }
