class RemoveDefaultsFromJobCounts < ActiveRecord::Migration
  def change
    change_column :jobs, :queued_count, :integer, null: true, default: nil
    change_column :jobs, :running_count, :integer, null: true, default: nil
    change_column :jobs, :passed_count, :integer, null: true, default: nil
    change_column :jobs, :failed_count, :integer, null: true, default: nil
    change_column :jobs, :errored_count, :integer, null: true, default: nil
  end
end
