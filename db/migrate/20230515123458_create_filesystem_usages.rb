# frozen_string_literal: true

class CreateFilesystemUsages < ActiveRecord::Migration[7.0]
  def change
    create_table :filesystem_usages do |t|
      t.float :used_percent
      t.timestamps
    end
  end
end
