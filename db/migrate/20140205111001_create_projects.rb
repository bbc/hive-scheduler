class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.references :user,           index: true
      t.string     :project_name,   null: false
      t.string     :platform,       null: false
      t.integer    :plan_id,        null: false
      t.string     :execution_type, null: false
      t.string     :repository,     null: false
      t.string     :chdir,          null: false
      t.timestamps
    end
  end
end
