class CreateWorkerQueueJoinTable < ActiveRecord::Migration
  def change
    create_join_table :workers, :hive_queues do |t|
      # t.index [:worker_id, :hive_queue_id]
      t.index [:hive_queue_id, :worker_id], unique: true
    end
  end
end
