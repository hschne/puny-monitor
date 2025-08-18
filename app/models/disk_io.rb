# frozen_string_literal: true

class DiskIO < ActiveRecord::Base
  class << self
    def average_io(start_time, group_by)
      [
        {name: "Read MB/s", data: average_for_period(:read_mb_per_sec, start_time, group_by)},
        {name: "Write MB/s", data: average_for_period(:write_mb_per_sec, start_time, group_by)}
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
