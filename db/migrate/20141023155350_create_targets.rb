class CreateTargets < ActiveRecord::Migration
  def change
    create_table :targets do |t|
      t.string :name
      t.string :icon
      t.references :fields, index: true

      t.timestamps
    end
  end
end
