# frozen_string_literal: true

class FilesystemUsage < ApplicationModel
  def self.average_usage(start_time, minutes)
    where(created_at: start_time..)
      .group_by_time(minutes)
      .average(Arel.sql("ROUND(used_percent, 2)"))
  end
end
