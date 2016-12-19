class CreateBatchAssets < ActiveRecord::Migration
  def change
    create_table :batch_assets do |t|
      t.references :batch, index: true
      t.references :asset, index: true

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Project.all.each do |p|
          p.batches.all.each do |b|
            p.assets.where(version: b.version).each do |a|
              BatchAsset.create! batch: b, asset: a
            end
          end
        end
      end
    end
  end
end
