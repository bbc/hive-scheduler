class DeleteTargetFields < ActiveRecord::Migration

  class ExecutionTypeField20141027160927 < ActiveRecord::Base
    self.table_name = "execution_type_fields"
  end

  def up
    ExecutionTypeField20141027160927.where(type: "TargetField").delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
