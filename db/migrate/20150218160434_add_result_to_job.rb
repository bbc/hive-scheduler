class AddResultToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :result, :string
  end
end
