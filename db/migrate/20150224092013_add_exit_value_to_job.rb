class AddExitValueToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :exit_value, :integer
  end
end
