require 'spec_helper'

describe Job do

  it { should be_a(Job::JobValidations) }
  it { should be_a(Job::JobStateMachine) }
  it { should be_a(Job::JobChart) }
  it { should be_a(Job::JobArtifacts) }
  it { should be_a(Job::JobAssociations) }
  it { should serialize(:execution_variables).as(::ActiveRecord::Coders::JSON) }
  it { should serialize(:reservation_details).as(::ActiveRecord::Coders::JSON) }

  describe "delegates" do
    it { should delegate_method(:queue_name).to(:job_group) }
  end

  describe 'scopes' do

    describe 'active' do

      let!(:completed_jobs) { Fabricate.times(2, :job, state: :complete) }
      let!(:errored_jobs) { Fabricate.times(2, :job, state: :errored) }

      let!(:retried_jobs) do
        errored_jobs.collect do |errored_job|
          Fabricate(:job, state: :complete, original_job_id: errored_job.id)
        end
      end

      it "only fetches active jobs" do
        expect(Job.active).to eq (completed_jobs | retried_jobs)
      end
    end

    describe "running" do

      let!(:running_jobs) { Fabricate.times(5, :running_job) }
      let!(:reserved_jobs) { Fabricate.times(4, :reserved_job) }
      let!(:completed_jobs) { Fabricate.times(3, :completed_job) }
      let!(:errored_jobs) { Fabricate.times(2, :errored_job) }

      subject { Job.running }

      it { should eq running_jobs }
    end
  end

  describe 'default values' do

    let(:job) { Fabricate(:job, queued_count: 0) }
    subject { job }

    its(:queued_count) { should eq 0 }
    its(:running_count) { should be_nil }
    its(:passed_count) { should be_nil }
    its(:failed_count) { should be_nil }
    its(:errored_count) { should be_nil }
  end

  describe "instance methods" do

    let(:job) { Fabricate(:job, queued_count: 0) }

    describe "#can_cancel?" do

      let(:job) { Fabricate(:job, state: job_state, result: job_result) }

      context 'job is in a running state' do

        let(:job_state) { 'running' }
        let(:job_result) { nil }

        it 'can NOT be cancelled' do
          expect(job.can_cancel?).to be_false
        end
      end

      context 'the job is queueing' do
        let(:job_state) { 'queued' }
        let(:job_result) { nil }

        it 'can be cancelled' do
          expect(job.can_cancel?).to be_true
        end
      end
    end
    
    describe "#cancel" do

      let(:job) { Fabricate(:job, state: job_state, result: job_result) }

      context 'job is in a queued state' do

        let(:job_state) { 'queued' }
        let(:job_result) { nil }
        
        before(:each) { job.cancel }

        it 'moves to a cancelled state' do
          expect(job.state).to eq "cancelled"
        end
        
        it "can't be cancelled a second time" do
          expect(job.can_cancel?).to be_false
        end
      end
      
      context 'the job is queueing' do
        let(:job_state) { 'queued' }
        let(:job_result) { nil }

        it 'can be cancelled' do
          expect(job.can_cancel?).to be_true
        end
      end
    end

    describe "#can_retry?" do

      let(:job) { Fabricate(:job, state: job_state, result: job_result) }

      context "the job has not been retried" do
        context 'job is in a running state' do

          let(:job_state) { :running }
          let(:job_result) { nil }

          it 'can NOT be retried' do
            expect(job.can_retry?).to be_false
          end
        end

        context 'the job has passed' do
          let(:job_state) { :complete }
          let(:job_result) { "passed" }

          it 'can NOT be retried' do
            expect(job.can_retry?).to be_false
          end
        end

        context 'the job has errored' do

          let(:job_state) { "errored" }
          let(:job_result) { "errored" }

          it "can be retried" do
            expect(job.can_retry?).to be_true
          end
        end

        context 'the job has failed' do

          let(:job_state) { "complete" }
          let(:job_result) { "failed" }

          it "can be retried" do
            expect(job.can_retry?).to be_true
          end
        end
      end

      context "the job has previously been retried" do

        let(:job_state) { "errored" }
        let(:job_result) { "errored" }

        let!(:replacement_job) { Fabricate(:job, original_job: job) }

        it 'can NOT be retried' do
          expect(job.can_retry?).to be_false
        end
      end
    end

    describe "#retry" do

      before(:each) do
        job.stub(can_retry?: can_retry)
      end

      let(:passed_count) { 1 }
      let(:failed_count) { 2 }
      let(:errored_count) { 3 }
      let(:original_retry_count) { 4 }

      let(:job) { Fabricate(:job, passed_count: passed_count, failed_count: failed_count, errored_count: errored_count, retry_count: original_retry_count) }


      context "job can NOT be retried" do
        let(:can_retry) { false }

        it "returns nil as the job cant be retried" do
          expect(job.retry).to be_nil
        end

        it "does not create any new jobs" do
          expect { job.retry }.to_not change { Job.count }
        end
      end

      context "job can be retried" do
        let(:can_retry) { true }
        let(:new_job) { job.retry }

        it "returns a new job" do
          expect(new_job).to be_instance_of(Job)
        end

        it "creates a new job" do
          expect { new_job }.to change { Job.count }.by(1)
        end

        it "creates a pointer from the parent job to the new job" do
          new_job
          expect(job.replacement).to eq new_job
        end

        describe "the newly created job" do

          it "persisted the new job" do
            expect(new_job).to be_persisted
          end

          it "set the queued count to the same as the parent job would have originally had" do
            expect(new_job.queued_count).to eq(passed_count+failed_count+errored_count)
          end

          it "incremented the retry_count by one for the new job" do
            expect(new_job.retry_count).to eq(original_retry_count+1)
          end

          it 'copied the parents job name' do
            # TODO rename job_name to name
            expect(new_job.job_name).to eq(job.job_name)
          end

          it "belongs to the same job_group as the parent job" do
            expect(new_job.job_group).to eq(job.job_group)
          end

          it "points to its parent (original) job that it replaces" do
            expect(new_job.original_job).to eq job
          end

          it "copied over any execution_variables from the parent job" do
            expect(new_job.execution_variables).to eq job.execution_variables
          end
        end
      end
    end

    describe "#retried?" do

      let(:original_job) { Fabricate(:job) }

      context "job has not been retried" do

        it "returns false" do
          expect(original_job.retried?).to be_false
        end
      end

      context "job has been retried" do

        let!(:replacement_job) do
          Fabricate(:job, original_job: original_job)
        end

        it "returns true" do
          expect(original_job.retried?).to be_true
        end
      end
    end

    describe "#reservation_valid?" do

      before(:each) do
        Timecop.freeze(Time.now)
      end

      after(:each) do
        Timecop.return
      end

      let!(:job) { Fabricate(:job, state: job_state, reserved_at: reserved_at) }

      subject { job.reservation_valid? }

      context "job is reserved" do

        let(:job_state) { "reserved" }

        context "reservation is within permitted timeout bounds" do

          let(:reserved_at) { Time.now-1.second }

          it { should be_true }
        end

        context "reservation is outside of permitted timeout bounds" do

          let(:reserved_at) { Time.now-Chamber.env.job_reservation_timeout }

          it { should be_false }
        end
      end

      context "job is NOT reserved" do

        let(:reserved_at) { Time.now-1.second }
        let(:job_state) { :queued }

        it { should be_false }
      end
    end
  end
end
