class AddAssetColumnsToAsset < ActiveRecord::Migration
  def up
    add_attachment :assets, :asset
  end

  def down
    remove_attachment :assets, :asset
  end
end
