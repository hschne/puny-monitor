# frozen_string_literal: true

require "sys/filesystem"

class SystemUtils
  class << self
    def cpu_usage_percent
      prev_cpu = read_cpu_stat
      sleep(1)
      current_cpu = read_cpu_stat

      prev_idle = prev_cpu[:idle] + prev_cpu[:iowait]
      idle = current_cpu[:idle] + current_cpu[:iowait]

      prev_non_idle = prev_cpu[:user] + prev_cpu[:nice] + prev_cpu[:system] +
                      prev_cpu[:irq] + prev_cpu[:softirq] + prev_cpu[:steal]
      non_idle = current_cpu[:user] + current_cpu[:nice] + current_cpu[:system] +
                 current_cpu[:irq] + current_cpu[:softirq] + current_cpu[:steal]

      prev_total = prev_idle + prev_non_idle
      total = idle + non_idle

      total_diff = total - prev_total
      idle_diff = idle - prev_idle

      cpu_percentage = ((total_diff - idle_diff).to_f / total_diff * 100).round(2)
      [cpu_percentage, 100.0].min.round(2)
    end

    def cpu_load_average
      File.read("#{proc_path}/loadavg").split.take(3)
          .map(&:to_f)
          .map { |value| value.round(2) }
    end

    def memory_usage_percent
      mem_info = File.read("#{proc_path}/meminfo")
      total = mem_info.match(/MemTotal:\s+(\d+)/)[1].to_f
      free = mem_info.match(/MemFree:\s+(\d+)/)[1].to_f
      buffers = mem_info.match(/Buffers:\s+(\d+)/)[1].to_f
      cached = mem_info.match(/Cached:\s+(\d+)/)[1].to_f
      used = total - free - buffers - cached
      (used / total * 100).round(2)
    end

    def filesystem_usage_percent
      stat = Sys::Filesystem.stat(root_path)
      total_blocks = stat.blocks
      available_blocks = stat.blocks_available
      used_blocks = total_blocks - available_blocks
      used_percent = (used_blocks.to_f / total_blocks * 100).round(2)
      [used_percent, 100.0].min.round(2)
    end

    def disk_io_stats
      prev_stats = read_disk_stats
      sleep(1)
      curr_stats = read_disk_stats

      read_sectors = curr_stats[:read_sectors] - prev_stats[:read_sectors]
      write_sectors = curr_stats[:write_sectors] - prev_stats[:write_sectors]

      sector_size = 512
      read_mb_per_sec = (read_sectors * sector_size / 1_048_576.0).round(2)
      write_mb_per_sec = (write_sectors * sector_size / 1_048_576.0).round(2)

      {
        read_mb_per_sec:,
        write_mb_per_sec:
      }
    end

    def bandwidth_usage
      prev_stats = read_network_stats
      sleep(1)
      curr_stats = read_network_stats

      incoming_bytes = curr_stats[:rx_bytes] - prev_stats[:rx_bytes]
      outgoing_bytes = curr_stats[:tx_bytes] - prev_stats[:tx_bytes]

      bytes_to_mbits = 8.0 / 1_000_000 # Convert bytes to megabits
      {
        incoming_mbps: (incoming_bytes * bytes_to_mbits).round(2),
        outgoing_mbps: (outgoing_bytes * bytes_to_mbits).round(2)
      }
    end

    private

    def proc_path
      File.join(root_path, "proc")
    end

    def root_path
      ENV.fetch("ROOT_PATH", "/")
    end

    def read_cpu_stat
      cpu_stats = File.read("#{proc_path}/stat").lines.first.split(/\s+/)
      {
        user: cpu_stats[1].to_i,
        nice: cpu_stats[2].to_i,
        system: cpu_stats[3].to_i,
        idle: cpu_stats[4].to_i,
        iowait: cpu_stats[5].to_i,
        irq: cpu_stats[6].to_i,
        softirq: cpu_stats[7].to_i,
        steal: cpu_stats[8].to_i
      }
    end

    def read_disk_stats
      primary_disk = File.read("#{proc_path}/partitions")
                         .lines
                         .drop(2)
                         .first
                         .split
                         .last

      stats = File.read("#{proc_path}/diskstats")
                  .lines
                  .map(&:split)
                  .find { |line| line[2] == primary_disk }

      {
        read_sectors: stats[5].to_i,
        write_sectors: stats[9].to_i
      }
    end

    def read_network_stats
      primary_interface = File.read("#{proc_path}/net/route")
                              .lines
                              .drop(1)
                              .find { |line| line.split[1] == "00000000" }
                              &.split&.first
      stats = File.read("#{proc_path}/net/dev")
                  .lines
                  .map(&:split)
                  .find { |line| line[0].chomp(":") == primary_interface }

      {
        rx_bytes: stats[1].to_i,
        tx_bytes: stats[9].to_i
      }
    end
  end
end
