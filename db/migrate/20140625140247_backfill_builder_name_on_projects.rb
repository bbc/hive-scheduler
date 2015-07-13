class BackfillBuilderNameOnProjects < ActiveRecord::Migration

  class Project20140625140247 < ActiveRecord::Base
    self.table_name = :projects
  end

  def up
    Project20140625140247.update_all(builder_name: "test_rail")
  end

  def down
    Project20140625140247.update_all(builder_name: nil)
  end
end
