class AddAdditionalDataToJobGroups < ActiveRecord::Migration
  def change
    add_column :job_groups, :additional_information, :blob
  end
end
