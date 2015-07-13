class CreateCuratedQueues < ActiveRecord::Migration
  def change
    create_table :curated_queues do |t|
      t.string :name
      t.binary :queues

      t.timestamps
    end
  end
end
