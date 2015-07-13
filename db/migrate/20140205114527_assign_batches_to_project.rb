class AssignBatchesToProject < ActiveRecord::Migration
  def change
    remove_column :batches, :username, :string
    add_column    :batches, :project_id, :integer, null: false
    add_index     :batches, :project_id
  end
end
