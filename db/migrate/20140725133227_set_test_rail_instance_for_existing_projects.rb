class SetTestRailInstanceForExistingProjects < ActiveRecord::Migration

  class Project20140725133227 < ActiveRecord::Base
    self.table_name = :projects
    serialize :builder_options, JSON
  end

  def up
    Project20140725133227.reset_column_information
    Project20140725133227.find_each do |project|
      project.update(builder_options: project.builder_options.merge(test_rail_instance: "bbcsandbox"))
    end
  end

  def down
    Project20140725133227.find_each do |project|
      project.builder_options.delete("test_rail_instance")
      project.save
    end
  end
end
