# frozen_string_literal: true

class ApplicationModel < ActiveRecord::Base
  self.abstract_class = true

  scope :group_by_time, ->(minutes) {
    interval_seconds = minutes * 60
    group("strftime('%s', created_at) / #{interval_seconds} * #{interval_seconds}")
  }

  def self.group_format(minutes)
    interval_seconds = minutes * 60
    "strftime('%s', created_at) / #{interval_seconds} * #{interval_seconds}"
  end
end

