require "spec_helper"

module JobCommands

  describe StuckJobsForDeviceChecker do


    describe "validations" do
      it { should validate_presence_of(:device_id) }
    end

    describe "#perform" do

      let(:device_id) { 99 }
      let!(:passed_jobs_with_same_device_id) { Fabricate.times(5, :passed_job, device_id: device_id) }
      let!(:running_jobs_with_same_device_id) { Fabricate.times(5, :running_job, device_id: device_id) }
      let!(:running_jobs_with_different_device_ids) { Fabricate.times(5, :running_job) }

      let(:stuck_jobs_checker) { JobCommands::StuckJobsForDeviceChecker.new(device_id: device_id) }

      before(:each) do
        stuck_jobs_checker.perform
      end

      it "sets all previously running jobs with the given device id to errored" do
        statuses = running_jobs_with_same_device_id.collect do |job|
          job.reload.state
        end
        expect(statuses.uniq).to match_array(["errored"])
      end

      it "did not alter the state of jobs with none matching device ids" do
        statuses = running_jobs_with_different_device_ids.collect do |job|
          job.reload.state
        end
        expect(statuses.uniq).to match_array(["running"])
      end

      it "did not alter the state of passed jobs with matching device id" do
        statuses =passed_jobs_with_same_device_id.collect do |job|
          job.reload.state
        end
        expect(statuses.uniq).to match_array(["complete"])
      end
    end
  end
end
