require 'spec_helper'

describe JobGroup::JobGroupValidations do

  let(:job_group) { JobGroup.new }
  subject { job_group }

  it { should validate_presence_of(:batch) }
  it { should validate_presence_of(:name) }

  describe "validating associated batch" do

    before(:each) do
      job_group.batch = batch
      job_group.valid?
    end

    subject { job_group.errors[:batch] }

    context "batch is valid" do
      let(:batch) { Fabricate.build(:batch) }

      it { should be_empty }
    end

    context "batch is NOT valid" do
      let(:batch) do
        Fabricate.build(:batch) do
          name nil
        end
      end

      it { should_not be_empty }
    end
  end
end
