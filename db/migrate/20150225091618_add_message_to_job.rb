class AddMessageToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :message, :text
  end
end
