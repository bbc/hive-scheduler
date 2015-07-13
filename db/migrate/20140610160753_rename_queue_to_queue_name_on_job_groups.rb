class RenameQueueToQueueNameOnJobGroups < ActiveRecord::Migration
  def change
    rename_column :job_groups, :queue, :queue_name
  end
end
