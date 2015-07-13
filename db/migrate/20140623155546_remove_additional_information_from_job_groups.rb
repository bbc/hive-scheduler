class RemoveAdditionalInformationFromJobGroups < ActiveRecord::Migration

  class JobGroup20140623155546 < ActiveRecord::Base
    self.table_name = :job_groups

    serialize :execution_variables, JSON
    serialize :additional_information, JSON
  end

  def up
    remove_column :job_groups, :additional_information
  end

  def down
    add_column :job_groups, :additional_information, :blob

    JobGroup20140623155546.reset_column_information
    JobGroup20140623155546.where("execution_variables IS NOT NULL").find_each do |job_group|
      job_group.update(additional_information: { test_rail: job_group.execution_variables })
    end
  end
end
