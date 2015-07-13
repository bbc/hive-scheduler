class AddErrorCountToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :errored, :integer, null: false, default: 0
  end
end
