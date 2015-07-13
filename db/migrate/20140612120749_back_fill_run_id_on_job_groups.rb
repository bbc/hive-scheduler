class BackFillRunIdOnJobGroups < ActiveRecord::Migration

  class JobGroup20140612120749 < ActiveRecord::Base
    self.table_name = "job_groups"
    has_many :jobs, class_name: "Job20140612120749", foreign_key: :job_group_id
    serialize :additional_information, JSON
  end

  class Job20140612120749 < ActiveRecord::Base
    self.table_name = "jobs"
    belongs_to :job_group, class_name: "JobGroup20140612120749"
  end

  def up
    JobGroup20140612120749.reset_column_information
    JobGroup20140612120749.find_each do |job_group|
      run_id = job_group.jobs.first.run_id
      if run_id.present?
        job_group.additional_information = { test_rail: { run_id: run_id } }
        job_group.save!
      end
    end
  end

  def down
    JobGroup20140612120749.update_all(additional_information: nil)
  end
end
