# frozen_string_literal: true

require "active_record"
require "sqlite3"
require "yaml"

config_path = File.join(__dir__, "database.yml")
ActiveRecord::Base.configurations = YAML.load_file(config_path)
ActiveRecord::Base.establish_connection(:development)

# Loads all models
Dir["#{__dir__}/../app/models/*.rb"].each { |file| require file }
