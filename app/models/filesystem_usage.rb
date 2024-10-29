# frozen_string_literal: true

class FilesystemUsage < ActiveRecord::Base
  def self.average_usage(start_time, group_by)
    where(created_at: start_time..)
      .group_by_period(group_by, :created_at)
      .average(:used_percent)
      .transform_values { |value| value&.round(2) }
  end
end
