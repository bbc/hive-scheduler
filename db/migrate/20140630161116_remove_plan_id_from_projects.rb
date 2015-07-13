class RemovePlanIdFromProjects < ActiveRecord::Migration

  class Project20140630161116 < ActiveRecord::Base
    self.table_name = :projects

    serialize :builder_options, JSON
  end

  def up
    remove_column :projects, :plan_id
  end

  def down
    add_column :projects, :plan_id, :integer

    Project20140630161116.reset_column_information
    Project20140630161116.find_each do |project|
      project.update(plan_id: project.builder_options["test_rail_plan_id"]) if project.builder_options.present? && project.builder_options["test_rail_plan_id"].present?
    end
  end
end
