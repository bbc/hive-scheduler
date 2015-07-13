require 'spec_helper'

describe Batch::BatchScopes do


  describe "#latest_jobs" do

    let(:batch) { Fabricate(:batch) }

    let(:original_job_one) { Fabricate(:job, batch: batch) }
    let!(:job_one_retry) { Fabricate(:job, batch: batch, original_job: original_job_one) }

    let(:original_job_two) { Fabricate(:job, batch: batch) }
    let!(:job_two_first_retry) { Fabricate(:job, batch: batch, original_job: original_job_two) }
    let!(:job_two_second_retry) { Fabricate(:job, batch: batch, original_job: job_two_first_retry) }

    let!(:job_three) { Fabricate(:job, batch: batch) }

    let!(:jobs_belonging_to_other_batches) { Fabricate.times(10, :job) }

    it "returns the latest jobs only and discounts original jobs that have retries" do
      expect(batch.latest_jobs).to match_array([job_one_retry, job_two_second_retry, job_three])
    end
  end
end
