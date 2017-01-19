class AddInstallBuildToScripts < ActiveRecord::Migration
  def change
    add_column :scripts, :install_build, :boolean, default: false
  end
end
