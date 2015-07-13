class AddAssetToArtifact < ActiveRecord::Migration
  def up
    add_attachment :artifacts, :asset
  end

  def down
    remove_attachment :artifacts, :asset
  end
end
