require "spec_helper"

describe JobGroup::JobGroupAssociations do

  let(:job_group) { JobGroup.new }
  subject { job_group }

  it { should belong_to :batch }
  it { should have_many(:jobs).dependent(:destroy) }
end
