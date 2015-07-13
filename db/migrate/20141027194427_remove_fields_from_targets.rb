class RemoveFieldsFromTargets < ActiveRecord::Migration
  def change
    remove_column :targets, :fields_id, :integer
  end
end
