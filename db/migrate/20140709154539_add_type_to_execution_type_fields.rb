class AddTypeToExecutionTypeFields < ActiveRecord::Migration

  class ExecutionTypeField20140709154539 < ActiveRecord::Base
    self.table_name = :execution_type_fields
  end

  def up
    add_column :execution_type_fields, :type, :string
    ExecutionTypeField20140709154539.reset_column_information
    ExecutionTypeField20140709154539.update_all(type: "ExecutionVariableField")
  end

  def down
    remove_column :execution_type_fields, :type, :string
  end
end
