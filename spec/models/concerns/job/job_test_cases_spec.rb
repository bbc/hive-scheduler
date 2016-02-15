require 'spec_helper'

describe Job::JobTestCases do

  #let!(:batch) { Batch.new() }
  #let!(:job_group) { JobGroup.new(batch_id: batch.id) }
  #let!(:job) { Job.new(job_group_id: job_group.id ) }

  let(:job) { Fabricate(:job) }

  describe "#associate_test_cases" do
    
    context "Associating test cases with a job for the first time" do
      it 'creates test case association with just test names' do
        job.associate_test_cases('testname1', 'testname2')
        job.reload
        expect( job.test_cases.first ).to be_a TestCase
        expect( job.test_cases.count ).to eq 2
        expect( job.test_cases.collect {|tc| tc.name}).to eq ['testname1', 'testname2']
      end
      
      context 'Re-associating a test_case' do
 
        it "doesn't create duplicates" do         
          job.associate_test_cases('testname1', 'testname2')
          job.associate_test_cases('testname1')
          expect( job.test_results.count ).to eq 2
          expect( job.job_group.batch.project.test_cases.count ).to eq 2
        end
      end
            
    end
  end
  
  describe "associate_test_case_result" do
    
    let!(:job) { Fabricate(:job) }
    
    context "name provided, urn empty, pending result object" do
      
      before(:each) do
        job.associate_test_cases('test1')
      end
      
      context "urn never known" do
        it "updates status of pending result" do
          result = job.associate_test_case_result( name: 'test1', status: 'pass' )
      
          expect(result).to be_a TestResult
          expect(result.status).to eq 'pass'
        end
      end

      context "name and urn know" do
        it "updates status and urn of pending result" do
          result = job.associate_test_case_result( name: 'test1', urn: 'file/test1:50', status: 'pass' )
      
          expect(result.test_case.urn).to eq 'file/test1:50'
      
          expect(result).to be_a TestResult
          expect(result.status).to eq 'pass'
        end
      end
      
    end

    context "name and urn provided, no existing result object" do
      
      it "creates test_case and result object" do
        result = job.associate_test_case_result( name: 'test1', urn: 'file/test1:50', status: 'fail' )
      
        expect(result).to be_a TestResult
        expect(result.status).to eq 'fail'
      end
    end

    context "Second test result reported in for test case" do
      
      it "creates new test result object if result is reported in a second time" do
        result1 = job.associate_test_case_result( name: 'test1', urn: 'file/test1:50', status: 'fail' )
        result2 = job.associate_test_case_result( name: 'test1', urn: 'file/test1:50', status: 'fail' )
 
        expect( result1 ).to_not be result2
      end

    end
    
  end
end
