class AddExecTypeIdToProject < ActiveRecord::Migration
  def change
    remove_column :projects, :execution_type, :integer
    add_column :projects, :execution_type_id, :integer, null: false
    add_index :projects, :execution_type_id
  end
end
