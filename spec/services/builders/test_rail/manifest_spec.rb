require "spec_helper"

describe Builders::TestRail::Manifest do

  describe "constants" do

    describe "BUILDER_NAME" do
      subject { Builders::TestRail::Manifest::BUILDER_NAME }
      it { should eq "test_rail" }
    end

    describe "FRIENDLY_NAME" do
      subject { Builders::TestRail::Manifest::FRIENDLY_NAME }
      it { should eq "Test Rail Plan" }
    end

    describe "BATCH_BUILDER" do
      subject { Builders::TestRail::Manifest::BATCH_BUILDER }
      it { should eq Builders::TestRail::BatchBuilder }
    end
  end
end
