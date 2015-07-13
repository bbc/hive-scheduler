class BackfillTestRailBuilderOptionsOnProject < ActiveRecord::Migration

  class Project20140630160119 < ActiveRecord::Base
    self.table_name = :projects

    serialize :builder_options, JSON
  end

  def up
    Project20140630160119.reset_column_information
    Project20140630160119.find_each do |project|
      project.update(builder_options: { test_rail_plan_id: project.plan_id })
    end
  end

  def down
    Project20140630160119.update_all(builder_options: nil)
  end
end
