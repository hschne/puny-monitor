# frozen_string_literal: true

require_relative "config/environment"

require "sinatra/activerecord/rake"

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
      `docker run --rm \
        -v=/:/host:ro,rslave -v=puny-data:/puny-monitor/db \
        -e ROOT_PATH=/host \
        -p 80:4567 \
        hschne/puny-monitor:latest`
    end

    desc "Run  Docker interactive shell"
    task :shell do
      `docker run --rm \
        -v=/:/host:ro,rslave -v=puny-data:/puny-monitor/db \
        -e ROOT_PATH=/host \
        -p 80:4567 \
        -it \
        hschne/puny-monitor:latest \
        /bin/bash`
    end
  end

  task default: %i[test rubocop]
end
