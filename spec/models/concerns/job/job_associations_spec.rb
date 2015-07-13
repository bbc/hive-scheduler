require 'spec_helper'

describe Job::JobAssociations do

  let(:job) { Job.new }
  subject { job }

  it { should belong_to(:job_group) }
  it { should have_one(:batch).through(:job_group) }
  it { should have_one(:project).through(:batch) }
  it { should have_one(:execution_type).through(:project) }
  it { should have_one(:replacement).class_name("Job").with_foreign_key(:original_job_id) }
  it { should belong_to(:original_job).class_name("Job").with_foreign_key(:original_job_id) }
  it { should have_many(:artifacts) }

  # The below are tested twice for assurance as shoulda matchers do not exercise code as they only check definitions
  describe "replacement and original_job associations" do

    let!(:original_job) { Fabricate(:job) }
    let!(:replacement_job) { Fabricate(:job, original_job: original_job) }

    describe "#replacement" do
      subject { original_job.reload.replacement }

      it { should eq replacement_job }
    end

    describe "#original_job" do
      subject { replacement_job.reload.original_job }

      it { should eq original_job }
    end
  end
end
