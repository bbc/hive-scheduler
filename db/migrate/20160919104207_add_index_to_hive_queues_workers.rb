class AddIndexToHiveQueuesWorkers < ActiveRecord::Migration
  def change
    add_index :hive_queues_workers, :worker_id
  end
end
