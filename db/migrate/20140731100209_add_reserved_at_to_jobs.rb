class AddReservedAtToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :reserved_at, :timestamp
  end
end
