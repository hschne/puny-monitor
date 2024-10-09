# frozen_string_literal: true

require "active_record"
require "sqlite3"
require "yaml"

# Loads all models
Dir["#{__dir__}/../app/models/*.rb"].each { |file| require file }
