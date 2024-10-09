# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/system_utils"

class SystemUtilsTest < Minitest::Test
  def setup
    @utils = SystemUtils
  end

  def test_cpu_usage_percent
    system_value = `top -bn1 | grep "Cpu(s)" | sed "s/.*, *\\([0-9.]*\\)%* id.*/\\1/" | awk '{print 100 - $1}'`.to_f
    utils_value = @utils.cpu_usage_percent

    assert_in_delta system_value, utils_value, 5
  end

  def test_memory_usage_percent
    system_value = `free | grep Mem | awk '{print $3/$2 * 100.0}'`.to_f
    utils_value = @utils.memory_usage_percent

    assert_in_delta system_value, utils_value, 5
  end

  def test_filesystem_usage_percent
    system_value = `df / | tail -1 | awk '{print $5}' | sed 's/%//'`.to_f
    utils_value = @utils.filesystem_usage_percent

    assert_in_delta system_value, utils_value, 5
  end

  def test_cpu_load_average
    system_value = `cat /proc/loadavg | awk '{print $1, $2, $3}'`.split.map(&:to_f)
    utils_value = @utils.cpu_load_average

    assert_in_delta system_value[0], utils_value[0], 0.1
    assert_in_delta system_value[1], utils_value[1], 0.1
    assert_in_delta system_value[2], utils_value[2], 0.1
  end
end
