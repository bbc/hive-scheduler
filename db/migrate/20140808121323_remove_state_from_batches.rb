class RemoveStateFromBatches < ActiveRecord::Migration
  def change
    remove_column :batches, :state, :string
  end
end
