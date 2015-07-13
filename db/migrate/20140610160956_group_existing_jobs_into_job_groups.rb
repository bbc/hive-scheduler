class GroupExistingJobsIntoJobGroups < ActiveRecord::Migration

  class JobGroup20140610160956 < ActiveRecord::Base
    self.table_name = "job_groups"
    has_many :jobs, class_name: "Job20140610160956"
  end

  class Job20140610160956 < ActiveRecord::Base
    self.table_name = "jobs"
  end

  def up
    Job20140610160956.group(:batch_id, :queue_name).find_each do |grouped_job|


      group_name           = grouped_job.job_name.split("#").first
      job_group_attributes = { batch_id: grouped_job.batch_id, queue_name: grouped_job.queue_name }
      job_group            = JobGroup20140610160956.create!(job_group_attributes.merge(name: group_name))
      Job20140610160956.where(job_group_attributes).update_all(job_group_id: job_group.id)
    end
  end

  def down
    Job20140610160956.update_all(job_group_id: nil)
    JobGroup20140610160956.delete_all
  end
end
