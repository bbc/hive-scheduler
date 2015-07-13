class AddIndexToJob < ActiveRecord::Migration
  def change
    add_index(:jobs, :original_job_id)
  end
end
