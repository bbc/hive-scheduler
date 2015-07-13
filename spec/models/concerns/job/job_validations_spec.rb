require "spec_helper"

describe Job::JobValidations do

  let(:job) { Job.new }
  subject { job }

  it { should validate_numericality_of(:queued_count).is_greater_than_or_equal_to(0) }
  it { should validate_numericality_of(:running_count).is_greater_than_or_equal_to(0) }
  it { should validate_numericality_of(:passed_count).is_greater_than_or_equal_to(0) }
  it { should validate_numericality_of(:failed_count).is_greater_than_or_equal_to(0) }
  it { should validate_numericality_of(:errored_count).is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:job_group) }
end
