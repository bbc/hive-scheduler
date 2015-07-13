class AddRunIdToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :run_id, :integer
  end
end
