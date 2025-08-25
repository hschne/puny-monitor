# frozen_string_literal: true

class Bandwidth < ActiveRecord::Base
  class << self
    def average_usage(start_time, group_by)
      data = where(created_at: start_time..)
        .group("strftime('#{group_format(group_by)}', created_at)")
        .pluck(
          Arel.sql("strftime('#{group_format(group_by)}', created_at) as period"),
          Arel.sql("ROUND(AVG(incoming_mbps), 2) as avg_incoming"),
          Arel.sql("ROUND(AVG(outgoing_mbps), 2) as avg_outgoing")
        ).to_h { |period, incoming, outgoing|
          [period, {incoming: incoming, outgoing: outgoing}]
        }

      [
        {name: "Incoming Mbps", data: data.transform_values { |v| v[:incoming] }},
        {name: "Outgoing Mbps", data: data.transform_values { |v| v[:outgoing] }}
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
