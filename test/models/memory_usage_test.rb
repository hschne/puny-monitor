# frozen_string_literal: true

require "test_helper"

class MemoryUsageTest < ActiveSupport::TestCase
  test "average_usage returns correct data" do
    start_time = 1.day.ago
    minutes = 60

    MemoryUsage.create(used_percent: 75.0, created_at: 12.hours.ago)

    result = MemoryUsage.average_usage(start_time, minutes)

    assert_kind_of Hash, result
    assert_in_delta(75.0, result.values.compact.first)
  end
end
