class BatchAsset < ActiveRecord::Base
  belongs_to :batch
  belongs_to :asset
end
