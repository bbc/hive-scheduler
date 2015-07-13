class BackFillExecutionVariablesOnJobs < ActiveRecord::Migration
  class Job20140623162637 < ActiveRecord::Base
    self.table_name = :jobs

    serialize :execution_variables, JSON
    serialize :tests, Array
  end

  def up
    Job20140623162637.reset_column_information
    Job20140623162637.where("tests IS NOT NULL").find_each do |job|
      job.update(execution_variables: { tests: job.tests })
    end
  end

  def down
    Job20140623162637.update_all(execution_variables: nil)
  end
end
