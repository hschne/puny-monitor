# frozen_string_literal: true

class DiskIO < ApplicationModel
  def self.average_io(start_time, minutes)
    data = where(created_at: start_time..)
      .group_by_time(minutes)
      .pluck(
        Arel.sql("datetime(#{group_format(minutes)}, 'unixepoch') as period"),
        Arel.sql("ROUND(AVG(read_mb_per_sec), 2) as avg_read"),
        Arel.sql("ROUND(AVG(write_mb_per_sec), 2) as avg_write")
      )

    read = data.to_h { |period, read, _| [period, read] }
    write = data.to_h { |period, _, write| [period, write] }
    [
      {name: "Read MB/s", data: read},
      {name: "Write MB/s", data: write}
    ]
  end
end
