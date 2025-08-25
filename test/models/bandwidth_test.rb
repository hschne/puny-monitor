# frozen_string_literal: true

require "test_helper"

class BandwidthTest < ActiveSupport::TestCase
  test "average_usage returns correct data structure" do
    start_time = 1.day.ago
    group_by = :hour

    result = Bandwidth.average_usage(start_time, group_by)

    assert_equal 2, result.length
    assert_equal(["Incoming Mbps", "Outgoing Mbps"], result.map { |r| r[:name] })
    assert_kind_of Hash, result.first[:data]
  end

  test "average_usage returns correctly rounded values" do
    Bandwidth.create(incoming_mbps: 10, outgoing_mbps: 5, created_at: 1.hours.ago)

    result = Bandwidth.average_usage(1.day.ago, :hour)
    incoming_data = result.find { |r| r[:name] == "Incoming Mbps" }[:data]
    outgoing_data = result.find { |r| r[:name] == "Outgoing Mbps" }[:data]

    assert_equal 10, incoming_data.values.compact.first
    assert_equal 5, outgoing_data.values.compact.first
  end
end
