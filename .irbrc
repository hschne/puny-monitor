require "irb/completion"

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{Dir.home}/.irb-history"
IRB.conf[:PROMPT_MODE] = :SIMPLE

ENV["RACK_ENV"] ||= "development"

require "bundler/setup"
Bundler.require(:default, ENV.fetch("RACK_ENV", nil))

Dir["#{__dir__}/config/initializers/**/*.rb"].each { |file| require file }
Dir["#{__dir__}/app/models/*.rb"].each { |file| require file }
