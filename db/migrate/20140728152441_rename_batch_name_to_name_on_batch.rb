class RenameBatchNameToNameOnBatch < ActiveRecord::Migration
  def change
    rename_column :batches, :batch_name, :name
  end
end
