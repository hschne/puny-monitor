# frozen_string_literal: true

require "sinatra/base"
require "sinatra/reloader"
require "sinatra/activerecord"
require "securerandom"
require "sys/cpu"
require "rufus-scheduler"
require_relative "models/cpu_load"
require_relative "config/application"

module PunyMonitor
  class App < Sinatra::Base
    configure do
      set :erb, layout: :layout
      @scheduler = Rufus::Scheduler.new
    end

    configure :development do
      register Sinatra::Reloader
    end

    get "/" do
      version = Sys::CPU::VERSION
      avg = Sys::CPU.load_avg.join(", ")
      stats = Sys::CPU.cpu_stats
      cpu_loads = CpuLoad.order(created_at: :desc).limit(10)
      erb :index, locals: { version:, avg:, stats:, cpu_loads: }
    end

    @scheduler.every "5s" do
      CpuLoad.create(load_average: Sys::CPU.load_avg.first)
    end
  end
end
