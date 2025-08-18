# frozen_string_literal: true

require "test_helper"
require_relative "../app/scheduler"

class SchedulerTest < ActiveSupport::TestCase
  test "collect_data creates records for all models" do
    assert_difference ["CpuUsage.count", "CpuLoad.count", "MemoryUsage.count",
      "FilesystemUsage.count", "DiskIO.count", "Bandwidth.count"], 1 do
      PunyMonitor::Scheduler.collect_data
    end
  end
end
