# frozen_string_literal: true

class Bandwidth < ApplicationModel
  def self.average_usage(start_time, minutes)
    data = where(created_at: start_time..)
      .group_by_time(minutes)
      .pluck(
        Arel.sql("#{group_format(minutes)} as period"),
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
end
