class RemoveTestsPerJobFromBatches < ActiveRecord::Migration
  def change
    remove_column :batches, :tests_per_job, :integer
  end
end
