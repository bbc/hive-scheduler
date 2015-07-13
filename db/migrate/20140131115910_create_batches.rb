class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.integer :plan_id,    null: false
      t.string  :username
      t.string  :batch_name, null: false
      t.string  :state,      null: false
      t.timestamps
    end
  end
end
