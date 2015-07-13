class CreateJobGroups < ActiveRecord::Migration
  def change
    create_table :job_groups do |t|
      t.belongs_to :batch, index: true
      t.string :queue
      t.string :name

      t.timestamps
    end
  end
end
