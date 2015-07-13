class AddTestsPerJobToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :tests_per_job, :integer, null: false, default: 10
  end
end
