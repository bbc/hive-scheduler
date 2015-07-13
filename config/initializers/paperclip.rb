Paperclip::Attachment.default_options[:storage] = Chamber.env.attachment.storage


if Chamber.env.attachment.storage == "s3"
  s3_config = { s3_credentials: { bucket: Chamber.env.attachment.s3_bucket }, s3_permissions: { original: :private } }
  Paperclip::Attachment.default_options.merge!(s3_config)
end

# Paperclip.options[:content_type_mappings] = { out: "text/plain", log: "text/plain" }

# We want to be able to upload an file types and its highly unlikely that we will recieved spoofed files via daemons
# so for now we are turning off Paperclips spoof detection
# http://robots.thoughtbot.com/prevent-spoofing-with-paperclip
# http://stackoverflow.com/questions/21502887/cant-upload-image-using-paperclip-4-0-rails-3
require 'paperclip/media_type_spoof_detector'
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end
