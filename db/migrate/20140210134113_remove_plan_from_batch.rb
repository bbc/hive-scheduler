class RemovePlanFromBatch < ActiveRecord::Migration
  def change
    remove_column :batches, :plan_id, :integer
  end
end
