class RemoveTestsAndQueuesFields < ActiveRecord::Migration

  class Field20141104165034 < ActiveRecord::Base
    self.table_name = :fields
  end

  def up
    Field20141104165034.where(name: ["tests", "run_id"]).delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
