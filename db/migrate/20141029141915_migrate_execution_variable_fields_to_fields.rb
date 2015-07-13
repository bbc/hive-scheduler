class MigrateExecutionVariableFieldsToFields < ActiveRecord::Migration

  def up
    execute <<-SQL
        INSERT INTO fields (fields.name, fields.field_type, fields.owner_id, fields.owner_type, fields.created_at, fields.updated_at)
          SELECT execution_type_fields.name AS 'name', field_type, execution_type_id AS owner_id, "ExecutionType" as owner_type, created_at, NOW() AS updated_at
          FROM execution_type_fields
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
