# frozen_string_literal: true

class Bandwidth < ActiveRecord::Base
  class << self
    def average_usage(start_time, group_by)
      [
        {name: "Incoming Mbps", data: average_for_period(:incoming_mbps, start_time, group_by)},
        {name: "Outgoing Mbps", data: average_for_period(:outgoing_mbps, start_time, group_by)}
      ]
    end

    private

    def average_for_period(column, start_time, group_by)
      where(created_at: start_time..)
        .group_by_period(group_by, :created_at)
        .average(column)
        .transform_values { |value| value&.round(2) }
    end
  end
end
