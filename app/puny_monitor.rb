# frozen_string_literal: true

require "sinatra/base"
require "sinatra/reloader"
require "sinatra/activerecord"
require "securerandom"
require "sys/cpu"
require "rufus-scheduler"
require "chartkick"
require "groupdate"
require_relative "models/cpu_load"

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
      Sys::CPU.load_avg.join(", ")
      end_time = Time.now
      start_time = end_time - 1.hour
      cpu_loads = CpuLoad.where(created_at: start_time..end_time)
                         .group_by_minute(:created_at, n: 1, series: true)
                         .average(:load_average)
      erb :index, locals: { version:, cpu_loads: }
    end

    @scheduler.every "5s" do
      CpuLoad.create(load_average: Sys::CPU.load_avg.first)
    end
  end
end
