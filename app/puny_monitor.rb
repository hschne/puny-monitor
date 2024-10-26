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
      erb :index, locals: { params:, logo: }
    end

    get "/up" do
      200
    end

    get "/data/cpu_usage" do
      content_type :json
      cpu_loads = CpuUsage.where(created_at: start_time..)
                          .group_by_period(group_by, :created_at, expand_range: true)
                          .average(:used_percent)
                          .transform_values { |value| value&.round(2) }
      cpu_loads.to_json
    end

    get "/data/cpu_load" do
      content_type :json
      end_time = Time.now
      [
        { name: "1 minute", data: CpuLoad.where(created_at: start_time..end_time)
                                         .group_by_period(group_by, :created_at)
                                         .average(:one_minute)
                                         .transform_values { |value| value&.round(2) } },
        { name: "5 minutes", data: CpuLoad.where(created_at: start_time..end_time)
                                          .group_by_period(group_by, :created_at)
                                          .average(:five_minutes)
                                          .transform_values { |value| value&.round(2) } },
        { name: "15 minutes", data: CpuLoad.where(created_at: start_time..end_time)
                                           .group_by_period(group_by, :created_at)
                                           .average(:fifteen_minutes)
                                           .transform_values { |value| value&.round(2) } }
      ].to_json
    end

    get "/data/memory_usage" do
      content_type :json
      memory_usage = MemoryUsage.where(created_at: start_time..)
                                .group_by_period(group_by, :created_at)
                                .average(:used_percent)
                                .transform_values { |value| value&.round(2) }
      memory_usage.to_json
    end

    get "/data/filesystem_usage" do
      content_type :json
      filesystem_usage = FilesystemUsage.where(created_at: start_time..)
                                        .group_by_period(group_by, :created_at)
                                        .average(:used_percent)
                                        .transform_values { |value| value&.round(2) }
      filesystem_usage.to_json
    end

    get "/data/disk_io" do
      content_type :json
      [
        { name: "Read MB/s", data: DiskIO.where(created_at: start_time..)
                                         .group_by_period(group_by, :created_at)
                                         .average(:read_mb_per_sec)
                                         .transform_values { |value| value&.round(2) } },
        { name: "Write MB/s", data: DiskIO.where(created_at: start_time..)
                                          .group_by_period(group_by, :created_at)
                                          .average(:write_mb_per_sec)
                                          .transform_values { |value| value&.round(2) } }
      ].to_json
    end

    get "/data/bandwidth" do
      content_type :json
      group_by = group_by()
      [
        { name: "Incoming Mbps", data: Bandwidth.where(created_at: start_time..)
                                                .group_by_period(group_by, :created_at)
                                                .average(:incoming_mbps)
                                                .transform_values { |value| value&.round(2) } },
        { name: "Outgoing Mbps", data: Bandwidth.where(created_at: start_time..)
                                                .group_by_period(group_by, :created_at)
                                                .average(:outgoing_mbps)
                                                .transform_values { |value| value&.round(2) } }
      ].to_json
    end

    private

    def logo
      @logo ||= begin
        file = File.open("public/icon.svg")
        file.read
      end
    end

    def duration
      params[:duration] || "1d"
    end

    def start_time
      case duration
      when "1h" then 1.hour.ago
      when "3d" then 3.days.ago
      when "1w" then 1.week.ago
      when "1m" then 1.month.ago
      else 1.day.ago
      end
    end

    def group_by
      case duration
      when "1h", "1d" then :minute
      else :hour
      end
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
