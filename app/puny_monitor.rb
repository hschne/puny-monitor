# frozen_string_literal: true

require "sinatra/base"
require "sinatra/reloader"
require "sinatra/activerecord"
require "securerandom"
require "rufus-scheduler"
require "chartkick"
require "groupdate"
require_relative "models/cpu_load"
require_relative "models/memory_usage"
require_relative "models/filesystem_usage"
require_relative "../lib/system_utils"

require_relative "../config/application"
require_relative "../config/initializers/chartkick"

require "debug"

module PunyMonitor
  class App < Sinatra::Base
    configure do
      set :erb, layout: :layout
      set :public_folder, File.join(__dir__, "..", "public")
      @scheduler = Rufus::Scheduler.new
    end

    configure :development do
      register Sinatra::Reloader
    end

    get "/" do
      erb :index, locals: {}
    end

    get "/data/cpu" do
      content_type :json
      end_time = Time.now
      start_time = end_time - 1.hour
      cpu_loads = CpuLoad.where(created_at: start_time..end_time)
                         .group_by_minute(:created_at, n: 1, series: true)
                         .average(:load_average)
      cpu_loads.to_json
    end

    get "/data/memory" do
      content_type :json
      end_time = Time.now
      start_time = end_time - 1.hour
      memory_usage = MemoryUsage.where(created_at: start_time..end_time)
                                .group_by_minute(:created_at, n: 1, series: true)
                                .average(:used_percent)
      memory_usage.to_json
    end

    get "/data/filesystem" do
      content_type :json
      end_time = Time.now
      start_time = end_time - 1.hour
      filesystem_usage = FilesystemUsage.where(created_at: start_time..end_time)
                                        .group_by_minute(:created_at, n: 1, series: true)
                                        .average(:used_percent)
      filesystem_usage.to_json
    end

    @scheduler.every "5s" do
      CpuLoad.create(load_average: SystemUtils.cpu_load_average)
      MemoryUsage.create(used_percent: SystemUtils.memory_usage_percent)
      FilesystemUsage.create(used_percent: SystemUtils.filesystem_usage_percent)
    end
  end
end
