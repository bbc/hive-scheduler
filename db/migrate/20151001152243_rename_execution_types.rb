class RenameExecutionTypes < ActiveRecord::Migration
  def change
    rename_table :execution_types, :scripts
  end
end
