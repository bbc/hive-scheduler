class RenameRetryJobIdToOriginalJobIdOnJobs < ActiveRecord::Migration
  def change
    rename_column :jobs, :retry_job_id, :original_job_id
  end
end
