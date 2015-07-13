class RemoveTestsFromJobs < ActiveRecord::Migration

  class Job20140623163316 < ActiveRecord::Base
    self.table_name = :jobs

    serialize :execution_variables, JSON
    serialize :tests, Array
  end

  def up
    remove_column :jobs, :tests
  end

  def down
    add_column :jobs, :tests, :text
    Job20140623163316.where("execution_variables IS NOT NULL").find_each do |job|
      job.update(tests: job.execution_variables["tests"])
    end
  end
end
