class CreateTestCases < ActiveRecord::Migration
  def change
    create_table :test_cases do |t|
      t.string :name
      t.string :urn
      t.references :project, index: true

      t.timestamps
    end
  end
end
