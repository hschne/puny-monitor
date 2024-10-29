# frozen_string_literal: true

require "test_helper"

class BandwidthTest < ActiveSupport::TestCase
  test "average_usage returns correct data structure" do
    start_time = 1.day.ago
    group_by = :hour

    result = Bandwidth.average_usage(start_time, group_by)

    assert_equal 2, result.length
    assert_equal ["Incoming Mbps", "Outgoing Mbps"], result.map { |r| r[:name] }
    assert_kind_of Hash, result.first[:data]
  end

  test "average_for_period returns correct data" do
    start_time = 1.day.ago
    group_by = :hour

    Bandwidth.create(incoming_mbps: 10.0, outgoing_mbps: 5.0, created_at: 12.hours.ago)

    result = Bandwidth.send(:average_for_period, :incoming_mbps, start_time, group_by)

    assert_kind_of Hash, result
    assert_equal 10.0, result.values.compact.first
  end
end
