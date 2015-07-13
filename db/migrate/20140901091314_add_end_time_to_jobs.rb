class AddEndTimeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :end_time, :timestamp
  end
end
