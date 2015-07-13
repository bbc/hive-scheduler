require 'spec_helper'

describe Job::JobStateMachine do

  describe 'state machine' do


    #
    # Tests for the initial state of a job
    # i.e. queued jobs
    #
    describe 'initial state' do

      it 'should be queued' do
        Job.new.queued?.should be_true
      end
    end

    #
    # event machine trigger tests
    #
    describe "events" do
      


      #
      # Reserving jobs
      # queued -> reserved
      #
      describe "#reserve" do

        let(:job) { Fabricate(:job, state: state) }
        let(:reservation_details) { { pid: 999, hive: "three" } }

        let(:job_reservation_check) { double(JobCommands::JobReservationCheck, async: job_reservation_check_async) }
        let(:job_reservation_check_async) { double(JobCommands::JobReservationCheck, check_in: true) }

        before(:each) do
          Timecop.freeze(Time.now)
          JobCommands::JobReservationCheck.stub(new: job_reservation_check)
          job.reserve(reservation_details)
        end

        after(:each) do
          Timecop.return
        end

        context "job is queued and so can be reserved" do

          let(:state) { "queued" }

          it "updated the state to reserved" do
            expect(job.state).to eq "reserved"
          end

          it "set the reserved_at time" do
            expect(job.reserved_at).to eq(Time.now)
          end

          it "updated the reservation details as provided" do
            expect(job.reservation_details).to eq reservation_details
          end

          it "scheduled a JobReservationCheck to fire just after the reservation timeout has expired" do
            expect(JobCommands::JobReservationCheck).to have_received(:new)
            expect(job_reservation_check).to have_received(:async)
            expect(job_reservation_check_async).to have_received(:check_in).with(Chamber.env.job_reservation_timeout+1.second, job.id)
          end
        end
      end


      # 
      # Unreserving jobs; i.e. if a worker dies
      # reserved -> queued 
      #
      describe "#unreserve" do

        before(:each) do
          job.unreserve
        end

        context "job is already in a reserved state" do

          let(:job) { Fabricate(:reserved_job) }

          it "moves the job back to a queued state" do
            expect(job.state).to eq "queued"
          end

          it "sets the reservation_details to nil" do
            expect(job.reservation_details).to be_nil
          end

          it "sets the reserved_at time to nil" do
            expect(job.reserved_at).to be_nil
          end
        end
      end


      #
      # Entering the preparing phase
      # reserved -> preparing
      # i.e. worker is performing checkouts and setup
      #
      describe '#prepare' do

        let(:stuck_running_jobs_checker) { double(JobCommands::StuckRunningJobsChecker, async: stuck_running_jobs_checker_async) }
        let(:stuck_running_jobs_checker_async) { double(JobCommands::StuckRunningJobsChecker, check_in: true) }

        before(:each) do
          Timecop.freeze(start_time)
          JobCommands::StuckRunningJobsChecker.stub(new: stuck_running_jobs_checker)
          JobCommands::StuckJobsForDeviceChecker.stub(new: stuck_jobs_checker)
        end

        after(:each) do
          Timecop.return
        end

        let!(:job_start_result) { job.prepare(device_id) }
        let(:device_id)         { 44 }
        let(:stuck_jobs_checker) { double(JobCommands::StuckJobsForDeviceChecker, perform: nil) }

        context "job is in a reserved state" do

          let!(:job) { Fabricate(:reserved_job, queued_count: queued_count, reserved_at: reserved_at) }
          let(:queued_count) { 22 }
          let(:reserved_at) { Time.now }

          context "job was started within the reservation timeout period" do

            context "queued_count is nil" do
              let(:queued_count) { nil }
              it "does not update the running_count" do
                expect(job.running_count).to be_nil
              end
            end

            let(:start_time) { reserved_at + (Chamber.env.job_reservation_timeout-1) }

            it "provides the device id to the stuck jobs checker" do
              expect(JobCommands::StuckJobsForDeviceChecker).to have_received(:new).with(device_id: device_id)
            end

            it "cleared any stuck jobs triggered for the same device" do
              expect(stuck_jobs_checker).to have_received(:perform)
            end

            it "was able to start the job" do
              expect(job_start_result).to be_true
            end

            it "transitioned the job to a preparing state" do
              expect(job.preparing?).to be_true
            end

            it "updated running count from the current queued count" do
              expect(job.running_count).to eq queued_count
            end

            it "set the jobs queued count to zero" do
              expect(job.queued_count).to eq 0
            end

            it "updated the Job start time" do
              expect(job.start_time).to eq start_time
            end

            it "updated the jobs device_id" do
              expect(job.device_id).to eq device_id
            end

            it "scheduled a StuckJobsForDeviceChecker to fire just after the stuck running jobs timeout has expired" do
              expect(JobCommands::StuckJobsForDeviceChecker).to have_received(:new)
              expect(stuck_running_jobs_checker).to have_received(:async)
              expect(stuck_running_jobs_checker_async).to have_received(:check_in).with(Chamber.env.stuck_running_jobs_timeout)
            end
          end

          context "job was started outside of the reservation timeout period" do

            let(:start_time) { reserved_at + Chamber.env.job_reservation_timeout + 1 }

            it "was NOT able to start the job" do
              expect(job_start_result).to be_false
            end

            it "did not transition to a preparing state" do
              expect(job.preparing?).to be_false
            end
          end
        end

        context "job is NOT in a reserved state" do

          let(:start_time) { nil }

          ["queued", "preparing", "reserved", "analyzing", "complete"].each do |state|

            let!(:job) { Fabricate(:job, state: state) }

            it "was NOT able to start the job from an '#{state}' state" do
              expect(job_start_result).to be_false
            end
          end
        end
      end


      # 
      # Transition to running state
      # preparing -> running
      #
      describe "#start" do

        let(:job) { Fabricate(:job, state: state, :running_count => 1) }

        before(:each) do
          job.start
        end

        context "job in preparing state can transition to running" do

          let(:state) { "preparing" }

          it "updated the state to running" do
            expect(job.state).to eq "running"
          end

          it "maintains a running count of 1" do
            expect(job.running_count).to eq 1
          end
        end
      end


      # 
      # Transition to analyzing state
      # running -> analyzing
      #
      describe "#end" do

        let(:job) { Fabricate(:job, state: state, :running_count => 1) }

        before(:each) do
          job.end
        end
        
        context "job in running state can transition to analyzing" do
        
          let(:state) { "running" }
                                  
          it "updated the state to analyzing" do
            expect(job.state).to eq "analyzing"
          end                     

          it "maintains a running count of 1" do
            expect(job.running_count).to eq 1
          end
        end
      end


      #
      # Transition to final complete state
      # analyzing -> complete
      #
      describe "#complete" do

        let(:job) { Fabricate(:job, state: state) }

        before(:each) do
          Timecop.freeze(Time.now)
          job.complete
        end

        after(:each) do
          Timecop.return
        end
  
        context "job in analyzing state can transtion to complete" do

          let(:state) { "analyzing" }

          it "updated the state to complete" do
            expect(job.state).to eq "complete"
          end

          it "job is not longer running" do
            expect(job.running_count).to eq 0
          end

        end

      end


      #
      # Transition to cancelled state
      # queued/reserved => cancelled
      #
      describe "#cancel" do

        let(:job) { Fabricate(:job, state: state, queued_count: queued_count, running_count: running_count) }

        before(:each) do
          Timecop.freeze(Time.now)
          job.cancel
        end

        after(:each) do
          Timecop.return
        end
  
        context "queued job can be cancelled" do

          let(:state) { "queued" }
          let(:queued_count) { 1 }
          let(:running_count) { 0 }

          it "updated the state to cancelled" do
            expect(job.state).to eq "cancelled"
          end

          it "job is not longer queued" do
            expect(job.queued_count).to eq 0
          end
          
          it "errored count is updated" do
            expect(job.errored_count).to eq 1
          end

        end

        context "reserved job can be cancelled" do

          let(:state) { "queued" }
          let(:queued_count) { 1 }
          let(:running_count) { 0 }

          it "updated the state to cancelled" do
            expect(job.state).to eq "cancelled"
          end

          it "job is no longer queued" do
            expect(job.queued_count).to eq 0
          end
          
          it "errored count is updated" do
            expect(job.errored_count).to eq 1
          end

        end

      end

    end
  end
end
