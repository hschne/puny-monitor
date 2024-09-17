# frozen_string_literal: true

require "sinatra/base"
require "sinatra/reloader"
require "securerandom"
require "sys/cpu"

module PunyMonitor
  class App < Sinatra::Base
    configure do
      set :erb, layout: :layout
    end

    get "/" do
      version = Sys::CPU::VERSION
      avg = Sys::CPU.load_avg.join(", ")
      stats = Sys::CPU.cpu_stats
      erb :index, locals: { version:, avg:, stats: }
    end
  end
end
