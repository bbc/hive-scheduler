class CreateArtifacts < ActiveRecord::Migration
  def change
    create_table :artifacts do |t|
      t.references :job, index: true

      t.timestamps
    end
  end
end
