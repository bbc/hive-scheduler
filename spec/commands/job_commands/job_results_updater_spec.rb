require "spec_helper"

module JobCommands
  describe JobResultsUpdater do

    describe "validations" do
      it { should validate_presence_of(:job_id) }
    end

    describe "instance methods" do

      let(:reservation_command) { JobCommands::JobResultsUpdater.new(params) }

      describe "#perform" do

        context "job exists" do
          let(:job) { Fabricate(:job, running_count: 0, passed_count: 0, failed_count: 0, errored_count: 0) }

          let(:running_count) { 4 }
          let(:passed_count) { 3 }
          let(:failed_count) { 2 }
          let(:errored_count) { 1 }

          let(:params) { { job_id: job.id, running_count: running_count, passed_count: passed_count, failed_count: failed_count, errored_count: errored_count } }

          let!(:command_result) { reservation_command.perform }

          it "returns the job" do
            expect(command_result).to eq job
          end

          describe "the updated result counts" do
            subject { job.reload }

            its(:running_count) { should eq running_count }
            its(:passed_count) { should eq passed_count }
            its(:failed_count) { should eq failed_count }
            its(:errored_count) { should eq errored_count }
          end
        end

        context "job does not exist" do

          let(:params) { { job_id: -99} }

          it "does not catch any exceptions raised" do
            expect { reservation_command.perform }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
