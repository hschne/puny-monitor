# frozen_string_literal: true

puts "Seeding database with dummy metrics data for the past 24 hours..."

end_time = Time.current
start_time = end_time - 24.hours
records_count = 8640

puts "Creating #{records_count} records for each metric type..."

timestamps = (0...records_count).map { |i| start_time + (i * 10.seconds) }

cpu_data = timestamps.map do |timestamp|
  {
    used_percent: rand(5.0..95.0).round(2),
    created_at: timestamp,
    updated_at: timestamp
  }
end
CpuUsage.insert_all(cpu_data)
puts "✓ Created #{records_count} CPU usage records"

memory_data = timestamps.map do |timestamp|
  {
    used_percent: rand(10.0..90.0).round(2),
    created_at: timestamp,
    updated_at: timestamp
  }
end
MemoryUsage.insert_all(memory_data)
puts "✓ Created #{records_count} memory usage records"

filesystem_data = timestamps.map do |timestamp|
  {
    used_percent: rand(5.0..95.0).round(2),
    created_at: timestamp,
    updated_at: timestamp
  }
end
FilesystemUsage.insert_all(filesystem_data)
puts "✓ Created #{records_count} filesystem usage records"

cpu_load_data = timestamps.map do |timestamp|
  one_min = rand(0.1..4.0).round(2)
  {
    one_minute: one_min,
    five_minutes: (one_min + rand(-0.5..0.5)).clamp(0.1, 8.0).round(2),
    fifteen_minutes: (one_min + rand(-1.0..1.0)).clamp(0.1, 8.0).round(2),
    created_at: timestamp,
    updated_at: timestamp
  }
end
CpuLoad.insert_all(cpu_load_data)
puts "✓ Created #{records_count} CPU load records"

bandwidth_data = timestamps.map do |timestamp|
  {
    incoming_mbps: rand(0.1..50.0).round(2),
    outgoing_mbps: rand(0.1..20.0).round(2),
    created_at: timestamp,
    updated_at: timestamp
  }
end
Bandwidth.insert_all(bandwidth_data)
puts "✓ Created #{records_count} bandwidth records"

disk_io_data = timestamps.map do |timestamp|
  {
    read_mb_per_sec: rand(0.1..30.0).round(2),
    write_mb_per_sec: rand(0.1..15.0).round(2),
    created_at: timestamp,
    updated_at: timestamp
  }
end
DiskIO.insert_all(disk_io_data)
puts "✓ Created #{records_count} disk I/O records"

puts "\nSeeding completed! Total records created: #{records_count * 6}"
puts "Data covers: #{start_time.strftime('%Y-%m-%d %H:%M:%S')} to #{end_time.strftime('%Y-%m-%d %H:%M:%S')}"
