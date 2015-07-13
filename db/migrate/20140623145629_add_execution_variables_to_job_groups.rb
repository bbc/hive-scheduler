class AddExecutionVariablesToJobGroups < ActiveRecord::Migration
  def change
    add_column :job_groups, :execution_variables, :blob
  end
end
