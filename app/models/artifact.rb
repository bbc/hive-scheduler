class Artifact < ActiveRecord::Base
  belongs_to :job
  has_attached_file :asset, path: "#{Chamber.env.attachment.path_base}/artifacts/:id/:filename", url: "/artifacts/:id/:filename"
  validates_attachment_presence :asset
  do_not_validate_attachment_file_type :asset

  validates :job, presence: true
end
