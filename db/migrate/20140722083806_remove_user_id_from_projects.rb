class RemoveUserIdFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :user_id, :integer
  end
end
