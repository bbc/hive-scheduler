require 'spec_helper'

describe Batch::BatchValidations do


  subject { batch }
  let(:batch) { Batch.new }

  context "batch is not persisted" do

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:version) }
  end

  describe "validating associated project" do

    before(:each) do
      batch.project = project
      batch.valid?
    end

    subject { batch.errors[:project] }

    context "project is valid" do
      let(:project) { Fabricate.build(:project) }

      it { should be_empty }
    end

    context "project is NOT valid" do
      let(:project) do
        Fabricate.build(:project) do
          name nil
        end
      end

      it { should_not be_empty }
    end
  end
end
