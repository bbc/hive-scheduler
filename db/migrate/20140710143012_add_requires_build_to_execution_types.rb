class AddRequiresBuildToExecutionTypes < ActiveRecord::Migration
  def change
    add_column :execution_types, :requires_build, :boolean, default: true
  end
end
