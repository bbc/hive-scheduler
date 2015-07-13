class BackFillJobGroupExecutionVariables < ActiveRecord::Migration

  class JobGroup20140623154417 < ActiveRecord::Base
    self.table_name = :job_groups

    serialize :execution_variables, JSON
    serialize :additional_information, JSON
  end

  def up
    JobGroup20140623154417.reset_column_information
    JobGroup20140623154417.where("additional_information IS NOT NULL").find_each do |job_group|
      job_group.update(execution_variables: job_group.additional_information['test_rail'])
    end
  end

  def down
    JobGroup20140623154417.update_all(execution_variables: nil)
  end
end
