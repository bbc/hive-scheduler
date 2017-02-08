class AddAttachmentTarballToBatches < ActiveRecord::Migration
  def self.up
    change_table :batches do |t|
      t.attachment :tarball
    end
  end

  def self.down
    remove_attachment :batches, :tarball
  end
end
