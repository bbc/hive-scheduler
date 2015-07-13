class AddExecutionVariablesToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :execution_variables, :blob
  end
end
