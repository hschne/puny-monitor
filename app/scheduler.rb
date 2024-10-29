# frozen_string_literal: true

require_relative "../lib/system_utils"
require "debug"

module PunyMonitor
  class Scheduler
    class << self
      def collect_data
        CpuUsage.create(used_percent: SystemUtils.cpu_usage_percent)
        cpu_load_averages = SystemUtils.cpu_load_average
        CpuLoad.create(one_minute: cpu_load_averages[0],
                       five_minutes: cpu_load_averages[1],
                       fifteen_minutes: cpu_load_averages[2])
        MemoryUsage.create(used_percent: SystemUtils.memory_usage_percent)
        FilesystemUsage.create(used_percent: SystemUtils.filesystem_usage_percent)

        disk_io = SystemUtils.disk_io_stats
        DiskIO.create(read_mb_per_sec: disk_io[:read_mb_per_sec], write_mb_per_sec: disk_io[:write_mb_per_sec])

        bandwidth = SystemUtils.bandwidth_usage
        Bandwidth.create(incoming_mbps: bandwidth[:incoming_mbps], outgoing_mbps: bandwidth[:outgoing_mbps])
      end

      def cleanup_old_data
        one_month_ago = 1.month.ago
        [CpuUsage, CpuLoad, MemoryUsage, FilesystemUsage, DiskIO, Bandwidth].each do |model|
          model.where("created_at < ?", one_month_ago).delete_all
        end
      end
    end
  end
end
