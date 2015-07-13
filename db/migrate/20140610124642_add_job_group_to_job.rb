class AddJobGroupToJob < ActiveRecord::Migration
  def change
    add_reference :jobs, :job_group, index: true
  end
end
