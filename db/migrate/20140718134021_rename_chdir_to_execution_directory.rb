class RenameChdirToExecutionDirectory < ActiveRecord::Migration
  def change
    rename_column :projects, :chdir, :execution_directory
  end
end
