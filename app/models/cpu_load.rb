# frozen_string_literal: true

class CpuLoad < ApplicationModel
  def self.average_load(start_time, end_time, minutes)
    data = where(created_at: start_time..end_time)
      .group_by_time(minutes)
      .pluck(
        Arel.sql("#{group_format(minutes)} as period"),
        Arel.sql("ROUND(AVG(one_minute), 2) as avg_one"),
        Arel.sql("ROUND(AVG(five_minutes), 2) as avg_five"),
        Arel.sql("ROUND(AVG(fifteen_minutes), 2) as avg_fifteen")
      ).to_h { |period, one, five, fifteen|
        [period, {one: one, five: five, fifteen: fifteen}]
      }

    [
      {name: "1 minute", data: data.transform_values { |v| v[:one] }},
      {name: "5 minutes", data: data.transform_values { |v| v[:five] }},
      {name: "15 minutes", data: data.transform_values { |v| v[:fifteen] }}
    ]
  end
end
