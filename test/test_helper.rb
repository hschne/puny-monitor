# frozen_string_literal: true

ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "active_record"
require "sinatra/activerecord"
require "database_cleaner/active_record"

# Load the application
require File.expand_path("../config/environment", __dir__)

# Load the schema
load File.expand_path("../db/schema.rb", __dir__)

# Require all the model files
Dir[File.expand_path("../app/models/*.rb", __dir__)].sort.each { |file| require file }

# Configure Database Cleaner
DatabaseCleaner.strategy = :transaction

module MinitestTest
  class Test
    def setup
      DatabaseCleaner.start
    end

    def teardown
      DatabaseCleaner.clean
    end
  end
end
