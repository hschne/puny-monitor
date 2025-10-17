# frozen_string_literal: true

module PunyMonitor
  module Authorization
    def self.included(base)
      return unless authorize?

      base.use Rack::Auth::Basic, "Puny Monitor" do |username, password|
        username == self.username && password == self.password
      end
    end

    def self.username
      @username ||= ENV.fetch("PUNY_USERNAME", nil)
    end

    def self.password
      @password ||= ENV.fetch("PUNY_PASSWORD", nil)
    end

    def self.authorize?
      username && password
    end
  end
end
