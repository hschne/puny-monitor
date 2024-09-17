# frozen_string_literal: true

require "sinatra/base"
require "sinatra/reloader"
require "securerandom"

module PunyMonitor
  class App < Sinatra::Base
    configure do
      set :erb, layout: :layout
    end

    get "/" do
      erb :index
    end
  end
end
