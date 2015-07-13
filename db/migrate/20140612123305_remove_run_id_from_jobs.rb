class RemoveRunIdFromJobs < ActiveRecord::Migration

  class JobGroup20140612123305 < ActiveRecord::Base
    self.table_name = :job_groups
    has_many :jobs, class_name: "Job20140612123305", foreign_key: :job_group_id

    serialize :additional_information, JSON
  end

  class Job20140612123305 < ActiveRecord::Base
    self.table_name = :jobs
    belongs_to :job_group, class_name: "JobGroup20140612123305"
  end

  def up
    remove_column :jobs, :run_id
  end

  def down
    add_column :jobs, :run_id, :integer

    JobGroup20140612123305.where("additional_information IS NOT NULL").find_each do |job_group|
      run_id = job_group.additional_information.try(:[], 'test_rail').try(:[], 'run_id')
      Job20140612123305.where(job_group_id: job_group.id).update_all(run_id: run_id)
    end
  end
end
