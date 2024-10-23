# frozen_string_literal: true

class AddIndicesToCreatedAtColumns < ActiveRecord::Migration[6.1]
  def change
    add_index :bandwidths, :created_at
    add_index :cpu_loads, :created_at
    add_index :cpu_usages, :created_at
    add_index :disk_ios, :created_at
    add_index :filesystem_usages, :created_at
    add_index :memory_usages, :created_at
  end
end
