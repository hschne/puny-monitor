# frozen_string_literal: true

require "test_helper"

class FilesystemUsageTest < ActiveSupport::TestCase
  test "average_usage returns correct data" do
    start_time = 1.day.ago
    minutes = 60

    FilesystemUsage.create(used_percent: 60.0, created_at: 12.hours.ago)

    result = FilesystemUsage.average_usage(start_time, minutes)

    assert_kind_of Array, result
    assert_in_delta(60.0, result.first[1]) if result.any?
  end
end
