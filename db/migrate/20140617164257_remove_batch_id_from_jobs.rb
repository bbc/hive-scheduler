class RemoveBatchIdFromJobs < ActiveRecord::Migration
  def change
    remove_column :jobs, :batch_id, :integer
  end
end
