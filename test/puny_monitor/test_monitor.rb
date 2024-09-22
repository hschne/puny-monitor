# frozen_string_literal: true

require "test_helper"

module PunyMonitor
  class TestVersion < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil PunyMonitor::VERSION
    end
  end
end
