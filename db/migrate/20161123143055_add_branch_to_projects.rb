class AddBranchToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :branch, :string
  end
end
