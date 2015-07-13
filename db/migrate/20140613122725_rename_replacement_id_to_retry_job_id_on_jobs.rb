class RenameReplacementIdToRetryJobIdOnJobs < ActiveRecord::Migration
  def change
    rename_column :jobs, :replacement_id, :retry_job_id
  end
end
