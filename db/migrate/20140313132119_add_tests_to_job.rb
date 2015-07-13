class AddTestsToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :tests, :text
  end
end
