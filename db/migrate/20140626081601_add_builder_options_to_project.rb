class AddBuilderOptionsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :builder_options, :blob
  end
end
