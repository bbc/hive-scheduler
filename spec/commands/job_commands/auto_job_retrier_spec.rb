require "spec_helper"

describe JobCommands::AutoJobRetrier do

  describe "instance methods" do

    describe "#perform" do

      let(:maximum_auto_retries) { 3 }
      let(:batch) { Fabricate(:batch, number_of_automatic_retries: maximum_auto_retries) }
      let!(:original_job) { Fabricate(:failed_job) }

      before(:each) do
        Chamber.env.stub(maximum_auto_retries: maximum_auto_retries)
      end

      context "job has never been retried" do

        let!(:job_to_retry) { original_job }

        it "creates a clone of the job to retry" do
          expect {
            JobCommands::AutoJobRetrier.new(job: job_to_retry).perform
          }.to change(Job, :count).by(1)
        end
      end

      context "job has reached its maximum number of retries" do

        let(:first_retry) { Fabricate(:failed_job, original_job: original_job) }
        let(:second_retry) { Fabricate(:failed_job, original_job: first_retry) }
        let(:third_retry) { Fabricate(:failed_job, original_job: second_retry) }

        let!(:job_to_retry) { third_retry }

        it "does not create a new job" do
          expect {
            JobCommands::AutoJobRetrier.new(job: job_to_retry).perform
          }.to_not change(Job, :count)
        end
      end
    end
  end
end
