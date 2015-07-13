class AddRequiresBuildToTargets < ActiveRecord::Migration
  def change
    add_column :targets, :requires_build, :boolean, default: false
  end
end

