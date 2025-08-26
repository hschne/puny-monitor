# frozen_string_literal: true

require "test_helper"

class CpuLoadTest < ActiveSupport::TestCase
  test "average_load returns correct data structure" do
    start_time = 1.day.ago
    minutes = 60

    result = CpuLoad.average_load(start_time, minutes)

    assert_equal 3, result.length
    assert_equal(["1 minute", "5 minutes", "15 minutes"], result.map { |r| r[:name] })
    assert_kind_of Hash, result.first[:data]
  end

  test "average_load consolidates all three metrics in one query" do
    CpuLoad.create(one_minute: 1, five_minutes: 5, fifteen_minutes: 15, created_at: 1.hour.ago)

    result = CpuLoad.average_load(1.day.ago, 60)

    one_min_data = result.find { |r| r[:name] == "1 minute" }[:data]
    five_min_data = result.find { |r| r[:name] == "5 minutes" }[:data]
    fifteen_min_data = result.find { |r| r[:name] == "15 minutes" }[:data]

    assert_equal 1, one_min_data.values.compact.first
    assert_equal 5, five_min_data.values.compact.first
    assert_equal 15, fifteen_min_data.values.compact.first
  end
end
