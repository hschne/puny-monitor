# frozen_string_literal: true

require "test_helper"

class CpuLoadTest < ActiveSupport::TestCase
  test "average_load returns correct data structure" do
    start_time = 1.day.ago
    end_time = Time.now
    group_by = :hour

    result = CpuLoad.average_load(start_time, end_time, group_by)

    assert_equal 3, result.length
    assert_equal(["1 minute", "5 minutes", "15 minutes"], result.map { |r| r[:name] })
    assert_kind_of Hash, result.first[:data]
  end

  test "average_for_period returns correct data" do
    start_time = 1.day.ago
    end_time = Time.now
    group_by = :hour

    CpuLoad.create(one_minute: 1.0, five_minutes: 2.0, fifteen_minutes: 3.0, created_at: 12.hours.ago)

    result = CpuLoad.send(:average_for_period, :one_minute, start_time, end_time, group_by)

    assert_kind_of Hash, result
    assert_in_delta(1.0, result.values.compact.first)
  end
end
