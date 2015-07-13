class AddTargetIdToExecutionType < ActiveRecord::Migration
  def change
    add_column :execution_types, :target_id, :integer
  end
end
