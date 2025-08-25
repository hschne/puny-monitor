# frozen_string_literal: true

class Bandwidth < ApplicationModel
  def self.average_usage(start_time, minutes)
    data = where(created_at: start_time..)
      .group_by_time(minutes)
      .pluck(
        Arel.sql("datetime(#{group_format(minutes)}, 'unixepoch') as period"),
        Arel.sql("ROUND(AVG(incoming_mbps), 2) as avg_incoming"),
        Arel.sql("ROUND(AVG(outgoing_mbps), 2) as avg_outgoing")
      )

    incoming = data.to_h { |period, incoming, _| [period, incoming] }
    outgoing = data.to_h { |period, _, outgoing| [period, outgoing] }
    [
      {name: "Incoming Mbps", data: incoming},
      {name: "Outgoing Mbps", data: outgoing}
    ]
  end
end
