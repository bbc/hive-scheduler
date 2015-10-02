class RenameExecutionTypeIdInProjects < ActiveRecord::Migration
  def change
    rename_column :projects, :execution_type_id, :script_id
  end
end
