require 'spec_helper'
require "paperclip/matchers"

RSpec.configure do |config|
  config.include Paperclip::Shoulda::Matchers
end


describe Artifact do
  it { should belong_to(:job) }
  it { should validate_presence_of(:job) }

  it { should have_attached_file(:asset) }
  it { should validate_attachment_presence(:asset) }
end
