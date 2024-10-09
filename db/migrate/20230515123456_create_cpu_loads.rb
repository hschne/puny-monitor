# frozen_string_literal: true

class CreateCpuLoads < ActiveRecord::Migration[7.0]
  def change
    create_table :cpu_loads do |t|
      t.float :load_average
      t.timestamps
    end
  end
end
