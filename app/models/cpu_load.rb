# frozen_string_literal: true

class CpuLoad < ActiveRecord::Base
  def self.average_load(start_time, end_time, group_by)
    [
      {name: "1 minute", data: average_for_period(:one_minute, start_time, end_time, group_by)},
      {name: "5 minutes", data: average_for_period(:five_minutes, start_time, end_time, group_by)},
      {name: "15 minutes", data: average_for_period(:fifteen_minutes, start_time, end_time, group_by)}
    ]
  end

  def self.average_for_period(column, start_time, end_time, group_by)
    where(created_at: start_time..end_time)
      .group_by_period(group_by, :created_at)
      .average(column)
      .transform_values { |value| value&.round(2) }
  end
end
