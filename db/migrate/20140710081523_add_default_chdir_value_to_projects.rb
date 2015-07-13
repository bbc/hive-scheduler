class AddDefaultChdirValueToProjects < ActiveRecord::Migration
  def up
    change_column :projects, :chdir, :string, default: "."
  end

  def down
    change_column :projects, :chdir, :string, default: ""
  end
end
