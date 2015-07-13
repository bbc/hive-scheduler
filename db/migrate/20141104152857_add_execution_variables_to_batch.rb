class AddExecutionVariablesToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :execution_variables, :blob
  end
end
