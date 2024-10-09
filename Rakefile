# frozen_string_literal: true

require "bundler/gem_tasks"

require "sinatra/activerecord/rake"
require_relative "app/puny_monitor"

if PunyMonitor::App.development?
  require "minitest/test_task"
  Minitest::TestTask.create

  require "rubocop/rake_task"
  RuboCop::RakeTask.new

  namespace :docker do
    desc "Build Puny Monitor Docker image"
    task :build do
      sh "docker build -t hschne/puny-monitor:latest ."
    end

    desc "Push Puny Monitor Docker image"
    task :push do
      sh "docker push hschne/puny-monitor:latest"
    end

    desc "Run Docker container"
    task :run do
      sh "docker run --rm -v=/:/host:ro,rslave -v=puny-data:/puny-monitor/db -p 80:4567 -e PROC_PATH=/host/proc puny-monitor:latest"
    end

    desc "Run  Docker interactive shell"
    task :shell do
      sh "docker run --rm -v=/:/host:ro,rslave -v=puny-data:/puny-monitor/db -p 80:4567 -e PROC_PATH=/host/proc -it puny-monitor:latest /bin/bash"
    end
  end

  task default: %i[test rubocop]
end
