class RemoveQueueNameFromJobs < ActiveRecord::Migration

  class JobGroup20140612094456 < ActiveRecord::Base
    self.table_name = "job_groups"
    has_many :jobs, class_name: "Job20140612094456", foreign_key: :job_group_id
  end

  class Job20140612094456 < ActiveRecord::Base
    self.table_name = "jobs"
  end

  def up
    remove_column :jobs, :queue_name
  end

  def down


    add_column :jobs, :queue_name, :string

    JobGroup20140612094456.find_each do |job_group|
      Job20140612094456.where(job_group_id: job_group.id).update_all(queue_name: job_group.queue_name)
    end
  end
end
