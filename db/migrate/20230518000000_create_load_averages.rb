class CreateLoadAverages < ActiveRecord::Migration[7.0]
  def change
    create_table :load_averages do |t|
      t.float :one_minute
      t.float :five_minutes
      t.float :fifteen_minutes
      t.timestamps
    end
  end
end
