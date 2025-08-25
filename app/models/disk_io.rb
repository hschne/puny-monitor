# frozen_string_literal: true

class DiskIO < ApplicationModel
  def self.average_io(start_time, minutes)
    data = where(created_at: start_time..)
      .group_by_time(minutes)
      .pluck(
        Arel.sql("#{group_format(minutes)} as period"),
        Arel.sql("ROUND(AVG(read_mb_per_sec), 2) as avg_read"),
        Arel.sql("ROUND(AVG(write_mb_per_sec), 2) as avg_write")
      ).to_h { |period, read, write|
        [period, {read: read, write: write}]
      }

    [
      {name: "Read MB/s", data: data.transform_values { |v| v[:read] }},
      {name: "Write MB/s", data: data.transform_values { |v| v[:write] }}
    ]
  end
end
