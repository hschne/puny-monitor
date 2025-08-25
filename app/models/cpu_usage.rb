# frozen_string_literal: true

class CpuUsage < ActiveRecord::Base
  def self.average_usage(start_time, group_by)
    where(created_at: start_time..)
      .group_by_period(group_by, :created_at, expand_range: true)
      .average(Arel.sql("ROUND(used_percent, 2)"))
  end
end
