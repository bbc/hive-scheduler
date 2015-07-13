class AddReplacementIdToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :replacement_id, :integer
  end
end
