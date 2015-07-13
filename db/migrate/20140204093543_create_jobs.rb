class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.references :batch
      t.string     :job_name, null: false
      t.string     :state,    null: false
      t.integer    :queued,   null: false, default: 0
      t.integer    :running,  null: false, default: 0
      t.integer    :passed,   null: false, default: 0
      t.integer    :failed,   null: false, default: 0
      t.timestamps
    end

    add_index :jobs, :batch_id
  end
end
