class Batch < ActiveRecord::Base
  module BatchAttachments
    extend ActiveSupport::Concern

    included do

      has_attached_file :build, path: "#{Chamber.env.attachment.path_base}/builds/batches/:id/:filename", url: "/builds/batches/:id/:filename"
      validates_attachment_content_type :build, content_type: ['application/octet-stream', 'application/vnd.android.package-archive']
      validates_attachment_presence :build, if: Proc.new { |batch| batch.requires_build? }
    end
  end
end
