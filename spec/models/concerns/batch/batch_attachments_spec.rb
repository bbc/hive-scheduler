require 'spec_helper'
require "paperclip/matchers"

RSpec.configure do |config|
  config.include Paperclip::Shoulda::Matchers
end

describe Batch::BatchAttachments do

  let(:batch) { Batch.new.tap { |batch| batch.stub(requires_build?: requires_build) } }

  subject { batch }

  context "requires_build? is true" do

    let(:requires_build) { true }

    it { should have_attached_file(:build) }
    it { should validate_attachment_presence(:build) }
    it { should validate_attachment_content_type(:build).allowing(['application/octet-stream', 'application/vnd.android.package-archive']) }
  end

  context "requires_build? is false" do

    let(:requires_build) { false }

    it { should_not validate_attachment_presence(:build) }
  end
end
