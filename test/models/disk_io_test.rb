# frozen_string_literal: true

require "test_helper"

class DiskIOTest < ActiveSupport::TestCase
  test "average_io returns correct data structure" do
    start_time = 1.day.ago
    minutes = 60

    result = DiskIO.average_io(start_time, minutes)

    assert_equal 2, result.length
    assert_equal(["Read MB/s", "Write MB/s"], result.map { |r| r[:name] })
    assert_kind_of Hash, result.first[:data]
  end

  test "average_io consolidates read and write metrics" do
    DiskIO.create(read_mb_per_sec: 20, write_mb_per_sec: 10, created_at: 12.hours.ago)

    result = DiskIO.average_io(1.day.ago, 60)
    read_data = result.find { |r| r[:name] == "Read MB/s" }[:data]
    write_data = result.find { |r| r[:name] == "Write MB/s" }[:data]

    assert_equal 20, read_data.values.compact.first
    assert_equal 10, write_data.values.compact.first
  end
end
