# frozen_string_literal: true

require "sinatra/contrib"
require_relative "../lib/system_utils"

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

    get "/up" do
      200
    end

    get "/data/cpu_usage" do
      content_type :json
      end_time = Time.now
      start_time = end_time - 1.hour
      cpu_loads = CpuUsage.where(created_at: start_time..end_time)
                          .group_by_minute(:created_at, n: 1, series: true)
                          .average(:used_percent)
      cpu_loads.to_json
    end

    get "/data/cpu_load" do
      content_type :json
      end_time = Time.now
      start_time = end_time - 1.hour
      [
        { name: "1 minute", data: CpuLoad.where(created_at: start_time..end_time)
                                         .group_by_minute(:created_at, n: 1, series: true)
                                         .average(:one_minute) },
        { name: "5 minutes", data: CpuLoad.where(created_at: start_time..end_time)
                                          .group_by_minute(:created_at, n: 1, series: true)
                                          .average(:five_minutes) },
        { name: "15 minutes", data: CpuLoad.where(created_at: start_time..end_time)
                                           .group_by_minute(:created_at, n: 1, series: true)
                                           .average(:fifteen_minutes) }
      ].to_json
    end

    get "/data/memory_usage" do
      content_type :json
      end_time = Time.now
      start_time = end_time - 1.hour
      memory_usage = MemoryUsage.where(created_at: start_time..end_time)
                                .group_by_minute(:created_at, n: 1, series: true)
                                .average(:used_percent)
      memory_usage.to_json
    end

    get "/data/filesystem_usage" do
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
        { name: "Incoming Mbps", data: Bandwidth.where(created_at: start_time..end_time)
                                                .group_by_minute(:created_at, n: 1, series: true)
                                                .average(:incoming_mbps) },
        { name: "Outgoing Mbps", data: Bandwidth.where(created_at: start_time..end_time)
                                                .group_by_minute(:created_at, n: 1, series: true)
                                                .average(:outgoing_mbps) }
      ].to_json
    end

    @scheduler.every "5s" do
      CpuUsage.create(used_percent: SystemUtils.cpu_usage_percent)
      cpu_load_averages = SystemUtils.cpu_load_average
      CpuLoad.create(one_minute: cpu_load_averages[0],
                     five_minutes: cpu_load_averages[1],
                     fifteen_minutes: cpu_load_averages[2])
      MemoryUsage.create(used_percent: SystemUtils.memory_usage_percent)
      FilesystemUsage.create(used_percent: SystemUtils.filesystem_usage_percent)

      disk_io = SystemUtils.disk_io_stats
      DiskIO.create(read_mb_per_sec: disk_io[:read_mb_per_sec], write_mb_per_sec: disk_io[:write_mb_per_sec])

      bandwidth = SystemUtils.bandwidth_usage
      Bandwidth.create(incoming_mbps: bandwidth[:incoming_mbps], outgoing_mbps: bandwidth[:outgoing_mbps])
    end

    @scheduler.every "1h" do
      CpuUsage.where("created_at < ?", 1.month.ago).destroy_all
      CpuLoad.where("created_at < ?", 1.month.ago).destroy_all
      MemoryUsage.where("created_at < ?", 1.month.ago).destroy_all
      FilesystemUsage.where("created_at < ?", 1.month.ago).destroy_all
      DiskIO.where("created_at < ?", 1.month.ago).destroy_all
      BandwidthUsage.where("created_at < ?", 1.month.ago).destroy_all
    end
  end
end
