# frozen_string_literal: true

require "test_helper"

class CpuUsageTest < ActiveSupport::TestCase
  test "average_usage returns correct data" do
    start_time = 1.day.ago
    minutes = 60

    CpuUsage.create(used_percent: 50.0, created_at: 12.hours.ago)

    result = CpuUsage.average_usage(start_time, minutes)

    assert_kind_of Hash, result
    assert_in_delta(50.0, result.values.compact.first)
  end
end
