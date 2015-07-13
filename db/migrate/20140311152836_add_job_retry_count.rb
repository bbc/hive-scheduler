class AddJobRetryCount < ActiveRecord::Migration
  def change
    add_column :jobs, :retry_count, :integer, null: false, default: 0
  end
end
