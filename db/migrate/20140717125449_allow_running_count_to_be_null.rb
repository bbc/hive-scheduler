class AllowRunningCountToBeNull < ActiveRecord::Migration
  def up
    change_column :jobs, :running_count, :integer, :null => true
  end

  def down
    change_column :jobs, :running_count, :integer, :null => false, default: 0
  end
end
