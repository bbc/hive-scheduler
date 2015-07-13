class AddTargetInformationToBatches < ActiveRecord::Migration
  def change
    add_column :batches, :target_information, :blob
  end
end
