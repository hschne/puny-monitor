class CreateDiskIos < ActiveRecord::Migration[7.0]
  def change
    create_table :disk_ios do |t|
      t.float :read_mb_per_sec
      t.float :write_mb_per_sec
      t.timestamps
    end
  end
end
