# frozen_string_literal: true

require "test_helper"

class DiskIOTest < ActiveSupport::TestCase
  test "average_io returns correct data structure" do
    start_time = 1.day.ago
    group_by = :hour

    result = DiskIO.average_io(start_time, group_by)

    assert_equal 2, result.length
    assert_equal ["Read MB/s", "Write MB/s"], result.map { |r| r[:name] }
    assert_kind_of Hash, result.first[:data]
  end

  test "average_for_period returns correct data" do
    start_time = 1.day.ago
    group_by = :hour

    DiskIO.create(read_mb_per_sec: 20.0, write_mb_per_sec: 10.0, created_at: 12.hours.ago)

    result = DiskIO.send(:average_for_period, :read_mb_per_sec, start_time, group_by)

    assert_kind_of Hash, result
    assert_equal 20.0, result.values.compact.first
  end
end
