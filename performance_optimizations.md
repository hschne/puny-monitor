# Performance Optimization Recommendations

## Current Performance Issues

### 1. Multiple Queries Per Endpoint
- `CpuLoad.average_load()` executes 3 separate queries for 1/5/15 minute averages
- `Bandwidth.average_usage()` executes 2 queries for incoming/outgoing
- `DiskIO.average_io()` executes 2 queries for read/write

### 2. SQL Analysis
Current queries use `strftime('%Y-%m-%d %H:%M:00 UTC', created_at)` for grouping, which:
- Cannot use indexes efficiently
- Performs string manipulation on every row
- Prevents query optimization

## Optimization Solutions

### Solution 1: Single Query Multi-Column Aggregation

**Current CpuLoad (3 queries):**
```ruby
def self.average_load(start_time, end_time, group_by)
  [
    {name: "1 minute", data: average_for_period(:one_minute, start_time, end_time, group_by)},
    {name: "5 minutes", data: average_for_period(:five_minutes, start_time, end_time, group_by)},
    {name: "15 minutes", data: average_for_period(:fifteen_minutes, start_time, end_time, group_by)}
  ]
end
```

**Optimized (1 query):**
```ruby
def self.average_load(start_time, end_time, group_by)
  data = where(created_at: start_time..end_time)
    .group_by_period(group_by, :created_at)
    .pluck(
      Arel.sql("strftime('#{group_format(group_by)}', created_at) as period"),
      Arel.sql("AVG(one_minute) as avg_one"),
      Arel.sql("AVG(five_minutes) as avg_five"), 
      Arel.sql("AVG(fifteen_minutes) as avg_fifteen")
    ).to_h { |period, one, five, fifteen| 
      [period, {one: one&.round(2), five: five&.round(2), fifteen: fifteen&.round(2)}]
    }
    
  [
    {name: "1 minute", data: data.transform_values { |v| v[:one] }},
    {name: "5 minutes", data: data.transform_values { |v| v[:five] }},
    {name: "15 minutes", data: data.transform_values { |v| v[:fifteen] }}
  ]
end
```

**Performance Impact:** Reduces 3 queries to 1 (66% reduction)

### Solution 2: Add Time Bucket Columns

**Migration:**
```ruby
class AddTimeBucketsToMetricTables < ActiveRecord::Migration[6.1]
  def change
    %i[bandwidths cpu_loads cpu_usages disk_ios filesystem_usages memory_usages].each do |table|
      add_column table, :minute_bucket, :datetime
      add_column table, :hour_bucket, :datetime  
      add_index table, [:minute_bucket, :created_at]
      add_index table, [:hour_bucket, :created_at]
    end
  end
end ```

**In data collection (scheduler.rb):**
```ruby
# Round timestamps to minute/hour boundaries
minute_bucket = Time.now.beginning_of_minute
hour_bucket = Time.now.beginning_of_hour

CpuUsage.create!(
  used_percent: cpu_usage,
  minute_bucket: minute_bucket,
  hour_bucket: hour_bucket
)
```

**Optimized queries:**
```ruby
def self.average_usage(start_time, group_by)
  bucket_column = group_by == :minute ? :minute_bucket : :hour_bucket
  
  where("#{bucket_column} >= ?", start_time)
    .group(bucket_column)
    .average(:used_percent)
    .transform_keys(&:iso8601)
    .transform_values { |v| v&.round(2) }
end
```

**Performance Impact:** 
- Uses integer/datetime comparisons instead of string functions
- Leverages composite indexes effectively  
- ~3-5x faster for large datasets

### Solution 3: Database Views for Common Aggregations

For frequently accessed time ranges, create materialized views:

```sql
CREATE VIEW hourly_cpu_usage AS 
SELECT 
  strftime('%Y-%m-%d %H:00:00', created_at) as hour,
  AVG(used_percent) as avg_used_percent
FROM cpu_usages 
WHERE created_at >= datetime('now', '-7 days')
GROUP BY strftime('%Y-%m-%d %H:00:00', created_at);
```

## Implementation Priority

1. **High Impact, Low Effort:** Consolidate multi-column aggregations (Solution 1)
2. **Medium Impact, Medium Effort:** Add time bucket columns (Solution 2) 
3. **Low Impact, High Effort:** Database views (Solution 3)

## Expected Performance Improvements

- **Multi-series endpoints:** 50-66% fewer database queries
- **Large time ranges:** 3-5x faster with indexed time buckets
- **Memory usage:** Reduced by eliminating duplicate grouping operations
