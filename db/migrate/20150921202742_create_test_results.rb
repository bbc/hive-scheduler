class CreateTestResults < ActiveRecord::Migration
  def change
    create_table :test_results do |t|
      t.string :status
      t.text :message
      t.references :test_case, index: true
      t.references :job, index: true

      t.timestamps
    end
  end
end
