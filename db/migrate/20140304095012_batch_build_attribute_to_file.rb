class BatchBuildAttributeToFile < ActiveRecord::Migration
  def change
    remove_column  :batches, :build, :string
    add_attachment :batches, :build
  end
end
