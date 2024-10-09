# frozen_string_literal: true

class CreateBandwidthUsages < ActiveRecord::Migration[7.0]
  def change
    create_table :bandwidth_usages do |t|
      t.float :incoming_mbps
      t.float :outgoing_mbps
      t.timestamps null: false
    end
  end
end
