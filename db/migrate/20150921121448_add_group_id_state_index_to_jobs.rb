class AddGroupIdStateIndexToJobs < ActiveRecord::Migration
  def change
    add_index(:jobs, [:state, :job_group_id])
  end
end
