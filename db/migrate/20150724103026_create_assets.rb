class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.references :project, index: true
      t.string :name
      t.string :file
      t.string :version

      t.timestamps
    end
  end
end
