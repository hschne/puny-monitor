# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

require "sinatra/activerecord/rake"

require_relative "app/puny_monitor"
desc "Run PunyMonitor"
task :run do
  run PunyMonitor::App
end

task default: %i[test rubocop]
