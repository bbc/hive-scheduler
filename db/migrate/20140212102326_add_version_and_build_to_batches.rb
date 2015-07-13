class AddVersionAndBuildToBatches < ActiveRecord::Migration
  def change
    add_column :batches, :version, :string, null: false
    add_column :batches, :build,   :string, null: false
  end
end
