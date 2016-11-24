require "spec_helper"

describe JobCommands::JobReservation, type: :model do

  let(:reservation_command) { JobCommands::JobReservation.new(params) }
  let(:reservation_details) { { hive_id: 33, worker_pid: 222 } }
  let(:params) { { queue_names: queue_names, reservation_details: reservation_details } }

  describe "instance methods" do

    describe "queue_names=" do

      let(:params) { { queue_names: queue_names } }

      context "queue names are already provided as an array" do

        let(:queue_names) { ["queue_one", " queue_two", " queue_three "]  }

        it "accepts the queues as an array and strips any strings provided" do
          expect(reservation_command.queue_names).to match_array(%w(queue_one queue_two queue_three))
        end
      end

      context "single queue name is provided" do

        let(:queue_names) { "queue_one" }

        it "accepts the provided queue_name as is" do
          expect(reservation_command.queue_names).to eq [queue_names]
        end
      end

      context "multiple queue names are provided as a comma separated list" do

        let(:queue_names) { "queue_one , queue_two,  queue_three   " }

        it "accepts the queue names and explodes them into an array of (striped) strings" do
          expect(reservation_command.queue_names).to match_array(%w(queue_one queue_two queue_three))
        end
      end
    end

    describe "#perform" do

      before(:each) do
        Timecop.freeze(Time.now)
      end

      let(:job_group_one_queue_name) { "nexus-5" }
      let(:job_group_two_queue_name) { "nexus-4" }
      let(:job_group_one) { Fabricate(:job_group, hive_queue: Fabricate(:hive_queue, name: job_group_one_queue_name)) }
      let(:job_group_two) { Fabricate(:job_group, hive_queue: Fabricate(:hive_queue, name: job_group_two_queue_name)) }

      let!(:job_one) { Fabricate(:job, job_group: job_group_one, created_at: 1.days.ago, state: job_group_one_jobs_state) }
      let!(:job_two) { Fabricate(:job, job_group: job_group_one, created_at: 2.days.ago, state: job_group_one_jobs_state) }
      let!(:job_three) { Fabricate(:job, job_group: job_group_one, created_at: 3.days.ago, state: job_group_one_jobs_state) }
      let!(:job_four) { Fabricate(:job, job_group: job_group_two, created_at: 4.days.ago, state: :queued) }


      let(:reserved_job) { reservation_command.perform }

      context "jobs are available for reservation" do

        let(:job_group_one_jobs_state) { :queued }

        context "only a single queue name is provided" do

          let(:queue_names) { job_group_one_queue_name }

          context "the job could be reserved successfully" do

            it "selects the oldest queued job for the provided queue_name" do
              expect(reserved_job).to eq job_three
            end

            it "sets the reserved jobs reservation details" do
              expect(reserved_job.reservation_details).to eq reservation_details
            end

            it "sets the reserved jobs 'reserved_at' timestamp" do
              expect(reserved_job.reserved_at).to eq Time.now
            end
          end

          context "the job could not be reserved" do

            before(:each) do
              Job.any_instance.stub(:reserve)
            end

            it "has not reserved any jobs" do
              expect(Job.where(state: :reserved).count).to eq(0)
            end

            it "raises an error" do
              expect { reservation_command.perform }.to raise_error(JobCommands::JobReservationError, "Job #{job_three.id}:#{job_three.job_name}, could not be reserved")
            end
          end
        end

        context "multiple queue names are provided" do

          let(:queue_names) { [job_group_one_queue_name, job_group_two_queue_name] }

          it "selects the oldest queued job for the provided queue_name" do
            expect(reserved_job).to eq job_four
          end

          it "sets the reserved jobs reservation details" do
            expect(reserved_job.reservation_details).to eq reservation_details
          end

          it "sets the reserved jobs 'reserved_at' timestamp" do
            expect(reserved_job.reserved_at).to eq Time.now
          end

        end
      end

      context "no jobs are available for reservation" do

        let(:queue_names) { job_group_one_queue_name }

        let(:job_group_one_jobs_state) { :running }

        it "does not return a job" do
          expect(reserved_job).to be_nil
        end
      end
    end
  end
end
