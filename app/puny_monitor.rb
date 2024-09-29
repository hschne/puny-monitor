# frozen_string_literal: true

require "sinatra/base"
require "sinatra/reloader"
require "sinatra/activerecord"
require "securerandom"
require "sys/cpu"
require "sys/filesystem"
require "sys/memory"
require "rufus-scheduler"
require "chartkick"
require "groupdate"
require_relative "models/cpu_load"
require_relative "models/memory_usage"
require_relative "models/filesystem_usage"

require_relative "../config/application"

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
      version = Sys::CPU::VERSION
      erb :index, locals: { version: }
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
      CpuLoad.create(load_average: Sys::CPU.load_avg.first)

      memory = Sys::Memory
      used_percent = (memory.used.to_f / memory.total) * 100
      MemoryUsage.create(used_percent:)

      stat = Sys::Filesystem.stat("/")
      used_percent = (stat.blocks - stat.blocks_available).to_f / stat.blocks * 100
      FilesystemUsage.create(used_percent:)
    end
  end
end
