class RemovePlatformFromProject < ActiveRecord::Migration
  def change
    remove_column :projects, :platform, :string
  end
end
