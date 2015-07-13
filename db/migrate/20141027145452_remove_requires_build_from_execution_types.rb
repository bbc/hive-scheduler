class RemoveRequiresBuildFromExecutionTypes < ActiveRecord::Migration
  def change
    remove_column :execution_types, :requires_build, :boolean
  end
end
