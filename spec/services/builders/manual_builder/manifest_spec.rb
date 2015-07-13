require "spec_helper"

describe Builders::ManualBuilder::Manifest do

  describe "constants" do

    describe "BUILDER_NAME" do
      subject { Builders::ManualBuilder::Manifest::BUILDER_NAME }
      it { should eq "manual_builder" }
    end

    describe "FRIENDLY_NAME" do
      subject { Builders::ManualBuilder::Manifest::FRIENDLY_NAME }
      it { should eq "Manual" }
    end

    describe "BATCH_BUILDER" do
      subject { Builders::ManualBuilder::Manifest::BATCH_BUILDER }
      it { should eq Builders::ManualBuilder::BatchBuilder }
    end
  end
end
