class CreateExecutionTypes < ActiveRecord::Migration
  def change
    create_table :execution_types do |t|
      t.string :name,     null: false
      t.text   :template, null: false
      t.timestamps
    end
  end
end
