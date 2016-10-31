class AddRetriesToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :retries, :string
  end
end
