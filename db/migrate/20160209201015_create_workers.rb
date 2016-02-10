class CreateWorkers < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.integer :hive_id
      t.integer :pid
      t.integer :device_id

      t.timestamps
    end
  end
end
