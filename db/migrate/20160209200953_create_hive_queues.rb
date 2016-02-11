class CreateHiveQueues < ActiveRecord::Migration
  def change
    create_table :hive_queues do |t|
      t.string :name

      t.timestamps
    end
  end
end
