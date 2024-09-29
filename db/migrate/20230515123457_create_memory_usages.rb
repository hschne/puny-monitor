class CreateMemoryUsages < ActiveRecord::Migration[7.0]
  def change
    create_table :memory_usages do |t|
      t.float :used_percent
      t.timestamps
    end
  end
end
