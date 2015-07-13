class RenameJobCounts < ActiveRecord::Migration
  def change
    rename_column :jobs, :queued,  :queued_count
    rename_column :jobs, :running, :running_count
    rename_column :jobs, :passed,  :passed_count
    rename_column :jobs, :failed,  :failed_count
    rename_column :jobs, :errored, :errored_count
  end
end
