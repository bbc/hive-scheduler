class UpdateManualBuilderProjects < ActiveRecord::Migration
  def up
    Project.where(builder_name: "manual_cucumber_tags").update_all(builder_name: "manual_builder")
  end

  def down
    Project.where(builder_name: "manual_builder").update_all(builder_name: "manual_cucumber_tags")
  end
end
