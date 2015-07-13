class RenameProjectNameToNameOnProjects < ActiveRecord::Migration
  def change
    rename_column :projects, :project_name, :name
  end
end
