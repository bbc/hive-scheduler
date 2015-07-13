require "spec_helper"
require "sucker_punch/testing/inline"

describe JobCommands::StuckRunningJobsChecker, job: true do

  describe "instance methods" do

    before(:each) do
      Timecop.freeze(Time.now)
    end

    let!(:long_timed_out_running_job) { Fabricate(:running_job, start_time: (Time.now-(Chamber.env.stuck_running_jobs_timeout*2))) }
    let!(:just_timed_out_running_job) { Fabricate(:running_job, start_time: Time.now-Chamber.env.stuck_running_jobs_timeout) }
    let!(:just_started_running_job)   { Fabricate(:running_job, start_time: Time.now) }

    describe "#perform" do

      before(:each) do
        JobCommands::StuckRunningJobsChecker.new.async.perform
      end

      it "set the job that timed out a long time ago to errored" do
        expect(long_timed_out_running_job.reload.state).to eq "errored"
      end

      it "set the job that has just timed errored" do
        expect(just_timed_out_running_job.reload.state).to eq "errored"
      end

      it "did not set the running (non timed out) job to errored" do
        expect(just_started_running_job.reload.state).to eq "running"
      end
    end

    describe "#check_in" do

      pending "not testing check_in as cant currently find a way to test without using flakey sleeps"
    end
  end
end
