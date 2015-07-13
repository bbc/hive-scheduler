class AddExecutionVariablesToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :execution_variables, :blob
  end
end
