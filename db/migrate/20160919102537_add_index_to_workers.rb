class AddIndexToWorkers < ActiveRecord::Migration
  def change
    add_index :workers, ["hive_id", "pid", "device_id"], name: "index_hive_id_pid_on_workers"
  end
end
