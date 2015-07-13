class DeleteExecutionTypeFields < ActiveRecord::Migration
  def up
    drop_table :execution_type_fields
  end

  def down
    create_table :execution_type_fields do |t|
      t.string :name
      t.string :field_type
      t.references :execution_type, index: true

      t.timestamps
    end
  end
end
