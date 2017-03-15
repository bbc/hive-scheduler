class AddColumnsToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :script_start_time, :datetime
    add_column :jobs, :script_end_time, :datetime
  end
end
