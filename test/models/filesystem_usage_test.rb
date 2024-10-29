# frozen_string_literal: true

require "test_helper"

class FilesystemUsageTest < ActiveSupport::TestCase
  test "average_usage returns correct data" do
    start_time = 1.day.ago
    group_by = :hour

    FilesystemUsage.create(used_percent: 60.0, created_at: 12.hours.ago)

    result = FilesystemUsage.average_usage(start_time, group_by)

    assert_kind_of Hash, result
    assert_equal 60.0, result.values.compact.first
  end
end
