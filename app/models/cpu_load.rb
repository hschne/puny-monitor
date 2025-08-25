# frozen_string_literal: true

class CpuLoad < ActiveRecord::Base
  class << self
    def average_load(start_time, end_time, group_by)
      data = where(created_at: start_time..end_time)
        .group("strftime('#{group_format(group_by)}', created_at)")
        .pluck(
          Arel.sql("strftime('#{group_format(group_by)}', created_at) as period"),
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
