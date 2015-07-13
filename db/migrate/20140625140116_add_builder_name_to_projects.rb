class AddBuilderNameToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :builder_name, :string
  end
end
