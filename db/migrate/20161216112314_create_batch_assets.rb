class CreateBatchAssets < ActiveRecord::Migration
  def change
    create_table :batch_assets do |t|
      t.references :batch, index: true
      t.references :asset, index: true

      t.timestamps
    end
  end
end
