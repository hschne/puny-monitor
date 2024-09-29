module SystemUtils
  class << self
    def cpu_load_average
      load_avg_file = "#{proc_path}/loadavg"
      File.readlines(load_avg_file).first.to_f
    end

    def memory_usage_percent
      mem_info = File.read("#{proc_path}/meminfo")
      total = mem_info.match(/MemTotal:\s+(\d+)/)[1].to_f
      free = mem_info.match(/MemFree:\s+(\d+)/)[1].to_f
      buffers = mem_info.match(/Buffers:\s+(\d+)/)[1].to_f
      cached = mem_info.match(/Cached:\s+(\d+)/)[1].to_f
      used = total - free - buffers - cached
      (used / total * 100).round(2)
    rescue StandardError => e
      puts "Error reading memory usage: #{e.message}"
      0.0
    end

    def filesystem_usage_percent(_mount_point = "/")
      0.0
    end

    private

    def proc_path
      ENV.fetch("PROC_PATH", "/proc")
    end
  end
end
