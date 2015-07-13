class AddStartTimeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :start_time, :timestamp
  end
end
