require 'spec_helper'

describe Job::JobResult do

  describe '#calculate_result' do

    let(:job) { Fabricate(:job, state: 'analyzing', exit_value: exit_value,
                          passed_count: passed_count, failed_count: failed_count,
                          running_count: running_count, errored_count: errored_count) }
    
    before(:each) { job.complete }
 
    #
    # Behaviour of script-like jobs that don't report results, so
    # job status is determined by the exit_value
    #
    context "jobs that only have an exit value status" do
      
      let(:queued_count) { 0 }
      let(:running_count) { nil }
      let(:passed_count) { nil }
      let(:failed_count) { nil }
      let(:errored_count) { nil }

      context "non-zero" do

        let(:exit_value) { 1 }

        it "updated the state to complete" do
          expect(job.state).to eq "complete"
        end

        it "calculated a failure result" do
          expect(job.result).to eq "failed"
        end
        
        it "returns a failure status" do
          expect(job.status).to eq "failed"
        end
        
        it "updated running count to 0" do
          expect(job.running_count).to eq 0
        end

        it "leaves result counts as nil" do
          expect(job.passed_count).to be_nil
          expect(job.failed_count).to be_nil
          expect(job.errored_count).to be_nil
        end
        
      end
      
      context "zero" do

        let(:exit_value) { 0 }

        it "updated the state to complete" do
          expect(job.state).to eq "complete"
        end

        it "calculated a passed result" do
          expect(job.result).to eq "passed"
        end
        
        it "returns a passed status" do
          expect(job.status).to eq "passed"
        end
        
        it "updated running count to 0" do
          expect(job.running_count).to eq 0
        end

        it "leaves result counts as nil" do
          expect(job.passed_count).to be_nil
          expect(job.failed_count).to be_nil
          expect(job.errored_count).to be_nil
        end
        
      end
      
      context "nil exit value" do

        let(:exit_value) { nil }

        it "updated the state to complete" do
          expect(job.state).to eq "complete"
        end

        it "calculated a errored result" do
          expect(job.result).to eq "errored"
        end
        
        it "returns an errored status" do
          expect(job.status).to eq "errored"
        end
        
        it "updated running count to 0" do
          expect(job.running_count).to eq 0
        end

        it "leaves result counts as nil" do
          expect(job.passed_count).to be_nil
          expect(job.failed_count).to be_nil
          expect(job.errored_count).to be_nil
        end
        
      end
      
    end
    
    #
    # Behaviour of jobs that report result counts
    #
    context "jobs that have a result count" do
      
      let(:queued_count)  { 0 }
      let(:running_count) { 0 }
      let(:passed_count)  { 0 }
      let(:failed_count)  { 0 }
      let(:errored_count) { 0 }

      context "all pass" do
        let(:exit_value) { 0 }
        let(:passed_count)  { 10 }
        it "reports a passed result" do
          expect(job.status).to eq "passed"
        end
      end
      
      context "all fail" do
        let(:exit_value) { 1 }
        let(:failed_count)  { 10 }
        it "reports a failed result" do
          expect(job.status).to eq "failed"
        end
      end
      
      context "all error" do
        let(:exit_value) { 1 }
        let(:errored_count)  { 10 }
        it "reports an error result" do
          expect(job.status).to eq "errored"
        end
      end
      
      context "some fail" do
        let(:exit_value) { 1 }
        let(:passed_count)  { 5 }
        let(:failed_count)  { 5 }
        it "reports a failed result" do
          expect(job.status).to eq "failed"
        end
      end

      context "some error" do
        let(:exit_value) { 1 }
        let(:passed_count)  { 5 }
        let(:failed_count)  { 5 }
        let(:errored_count) { 5 }
        it "reports an errored result" do
          expect(job.status).to eq "errored"
        end
      end
      
    end
  end
end

