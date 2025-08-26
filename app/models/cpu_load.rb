# frozen_string_literal: true

class CpuLoad < ApplicationModel
  def self.average_load(start_time, minutes)
    data = where(created_at: start_time..)
      .group_by_time(minutes)
      .pluck(
        Arel.sql("datetime(#{group_format(minutes)}, 'unixepoch') as period"),
        Arel.sql("ROUND(AVG(one_minute), 2) as avg_one"),
        Arel.sql("ROUND(AVG(five_minutes), 2) as avg_five"),
        Arel.sql("ROUND(AVG(fifteen_minutes), 2) as avg_fifteen")
      )

    one = data.to_h { |period, one, _, _| [period, one] }
    five = data.to_h { |period, _, five, _| [period, five] }
    fifteen = data.to_h { |period, _, _, fifteen| [period, fifteen] }
    [
      {name: "1 minute", data: one},
      {name: "5 minutes", data: five},
      {name: "15 minutes", data: fifteen}
    ]
  end
end
