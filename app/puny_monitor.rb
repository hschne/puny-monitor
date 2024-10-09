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
require_relative "models/disk_io"
require_relative "models/bandwidth_usage"
require_relative "models/load_average"
require_relative "../lib/system_utils"

require_relative "../config/application"
require_relative "../config/initializers/chartkick"

require "debug"

module PunyMonitor
  class App < Sinatra::Base
    configure do
      register Sinatra::ActiveRecordExtension
      @scheduler = Rufus::Scheduler.new
    end

    configure :development do
      register Sinatra::Reloader
    end

    set :erb, layout: :layout
    set :public_folder, File.join(__dir__, "..", "public")
    set :database_file, "../config/database.yml"

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

    get "/data/disk_io" do
      content_type :json
      end_time = Time.now
      start_time = end_time - 1.hour
      [
        { name: "Read MB/s", data: DiskIO.where(created_at: start_time..end_time)
                                         .group_by_minute(:created_at, n: 1, series: true)
                                         .average(:read_mb_per_sec) },
        { name: "Write MB/s", data: DiskIO.where(created_at: start_time..end_time)
                                          .group_by_minute(:created_at, n: 1, series: true)
                                          .average(:write_mb_per_sec) }
      ].to_json
    end

    get "/data/bandwidth" do
      content_type :json
      end_time = Time.now
      start_time = end_time - 1.hour
      [
        { name: "Incoming Mbps", data: BandwidthUsage.where(created_at: start_time..end_time)
                                                     .group_by_minute(:created_at, n: 1, series: true)
                                                     .average(:incoming_mbps) },
        { name: "Outgoing Mbps", data: BandwidthUsage.where(created_at: start_time..end_time)
                                                     .group_by_minute(:created_at, n: 1, series: true)
                                                     .average(:outgoing_mbps) }
      ].to_json
    end

    get "/data/load_average" do
      content_type :json
      end_time = Time.now
      start_time = end_time - 1.hour
      [
        { name: "1 minute", data: LoadAverage.where(created_at: start_time..end_time)
                                             .group_by_minute(:created_at, n: 1, series: true)
                                             .average(:one_minute) },
        { name: "5 minutes", data: LoadAverage.where(created_at: start_time..end_time)
                                              .group_by_minute(:created_at, n: 1, series: true)
                                              .average(:five_minutes) },
        { name: "15 minutes", data: LoadAverage.where(created_at: start_time..end_time)
                                               .group_by_minute(:created_at, n: 1, series: true)
                                               .average(:fifteen_minutes) }
      ].to_json
    end

    @scheduler.every "5s" do
      CpuLoad.create(load_average: SystemUtils.cpu_usage_percent)
      cpu_load_averages = SystemUtils.cpu_load_average
      LoadAverage.create(one_minute: cpu_load_averages[0],
                         five_minutes: cpu_load_averages[1],
                         fifteen_minutes: cpu_load_averages[2])

      MemoryUsage.create(used_percent: SystemUtils.memory_usage_percent)

      FilesystemUsage.create(used_percent: SystemUtils.filesystem_usage_percent)
      disk_io = SystemUtils.disk_io_stats
      DiskIO.create(read_mb_per_sec: disk_io[:read_mb_per_sec], write_mb_per_sec: disk_io[:write_mb_per_sec])

      bandwidth = SystemUtils.bandwidth_usage
      BandwidthUsage.create(incoming_mbps: bandwidth[:incoming_mbps], outgoing_mbps: bandwidth[:outgoing_mbps])
    end
  end
end
