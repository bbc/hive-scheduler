class AddDeviceIdToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :device_id, :integer
    add_index  :jobs, :device_id
  end
end
