class AllowJobErroredCountToBeNil < ActiveRecord::Migration
  def change
    change_column :jobs, :errored_count, :integer, null: true
  end
end
