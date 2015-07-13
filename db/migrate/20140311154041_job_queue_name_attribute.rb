class JobQueueNameAttribute < ActiveRecord::Migration
  def change
    add_column :jobs, :queue_name, :string
  end
end
