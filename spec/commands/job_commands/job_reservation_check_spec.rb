require "spec_helper"
require "sucker_punch/testing/inline"

describe JobCommands::JobReservationCheck, job: true do

  describe "instance methods" do

    let(:job) { Fabricate(:reserved_job) }

    before(:each) do
      Job.any_instance.stub(reservation_valid?: reservation_valid)
    end

    describe "#perform" do

      before(:each) do
        JobCommands::JobReservationCheck.new.async.perform(job.id)
      end

      context "reservation is valid" do
        let(:reservation_valid) { true }

        it "unreserved the job" do
          expect(job.reload.state).to eq "reserved"
        end
      end

      context "reservation is NOT valid" do
        let(:reservation_valid) { false }

        it "reserved the job" do
          expect(job.reload.state).to eq "queued"
        end
      end
    end

    describe "#check_in" do

      before(:each) do
        JobCommands::JobReservationCheck.new.async.check_in(0, job.id)
        # This is the only way to simulate the timeout, even Timecop cant help due to Celluloid's threading.
        sleep(0.5)
      end

      context "reservation is valid" do
        let(:reservation_valid) { true }

        it "unreserved the job" do
          expect(job.reload.state).to eq "reserved"
        end
      end

      context "reservation is NOT valid" do
        let(:reservation_valid) { false }

        it "reserved the job" do
          expect(job.reload.state).to eq "queued"
        end
      end
    end
  end
end
