# frozen_string_literal: true

require "rufus-scheduler"
require_relative "scheduler"
require_relative "authorization"
require_relative "../lib/system_utils"

module PunyMonitor
  class App < Sinatra::Base
    # include Authorization

    configure do
      register Sinatra::ActiveRecordExtension
      @scheduler = Rufus::Scheduler.new
      @scheduler.every("10s") { Scheduler.collect_data }
      @scheduler.every("1h") { Scheduler.cleanup_old_data }
    end

    configure :development do
      register Sinatra::Reloader
    end

    set :erb, layout: :layout
    set :public_folder, File.join(__dir__, "..", "public")
    set :database_file, "../config/database.yml"

    get "/" do
      erb :index, locals: {params:, logo:}
    end

    get "/up" do
      200
    end

    get "/data/cpu_usage" do
      content_type :json
      CpuUsage.average_usage(start_time, interval).to_json
    end

    get "/data/cpu_load" do
      content_type :json
      CpuLoad.average_load(start_time, interval).to_json
    end

    get "/data/memory_usage" do
      content_type :json
      MemoryUsage.average_usage(start_time, interval).to_json
    end

    get "/data/filesystem_usage" do
      content_type :json
      FilesystemUsage.average_usage(start_time, interval).to_json
    end

    get "/data/disk_io" do
      content_type :json
      DiskIO.average_io(start_time, interval).to_json
    end

    get "/data/bandwidth" do
      content_type :json
      Bandwidth.average_usage(start_time, interval).to_json
    end

    private

    def logo
      @logo ||= begin
        file = File.open("public/icon.svg")
        file.read
      end
    end

    def start_time
      duration = params[:duration] || "1d"
      case duration
      when "1h" then 1.hour.ago
      when "3d" then 3.days.ago
      when "1w" then 1.week.ago
      when "1m" then 1.month.ago
      else 1.day.ago
      end
    end

    def interval
      (params[:interval] || "15").to_i
    end

    def chart_url(endpoint)
      query_params = []
      query_params << "duration=#{params[:duration]}" if params[:duration]
      query_params << "interval=#{params[:interval]}" if params[:interval]
      query_string = query_params.empty? ? "" : "?#{query_params.join("&")}"
      "#{endpoint}#{query_string}"
    end
  end
end
