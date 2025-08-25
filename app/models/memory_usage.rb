# frozen_string_literal: true

class MemoryUsage < ApplicationModel
  def self.average_usage(start_time, minutes)
    where(created_at: start_time..)
      .group_by_time(minutes)
      .pluck(
        Arel.sql("datetime(#{group_format(minutes)}, 'unixepoch') as period"),
        Arel.sql("ROUND(AVG(used_percent), 2) as avg_usage")
      ).to_h
  end
end
