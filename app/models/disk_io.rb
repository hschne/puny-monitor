# frozen_string_literal: true

class DiskIO < ActiveRecord::Base
  class << self
    def average_io(start_time, group_by)
      data = where(created_at: start_time..)
        .group("strftime('#{group_format(group_by)}', created_at)")
        .pluck(
          Arel.sql("strftime('#{group_format(group_by)}', created_at) as period"),
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

    private

    def group_format(group_by)
      case group_by
      when :minute then "%Y-%m-%d %H:%M:00 UTC"
      when :hour then "%Y-%m-%d %H:00:00 UTC"
      else "%Y-%m-%d %H:%M:00 UTC"
      end
    end
  end
end
