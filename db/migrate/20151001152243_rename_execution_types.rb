class RenameExecutionTypes < ActiveRecord::Migration
  def change
    rename_table :scripts, :scripts
  end
end
