require 'spec_helper'

describe JobsHelper do

  context '#full_job_name' do

    context 'retried job' do

      let(:job) { Fabricate.build(:job, retry_count: 3) }

      it 'should format name correctly' do
        helper.full_job_name(job).should == "#{job.job_name} [Retry #3]"
      end

    end

    context 'not a retried job' do

      let(:job) { Fabricate.build(:job) }

      it 'should format name correctly' do
        helper.full_job_name(job).should == job.job_name
      end

    end
    
    context '#job_duration' do
      
      
      it "should format a job duration of N seconds as 'Ns'" do
        job = Fabricate.build(:job, :start_time => (Time.now - 5), :end_time => Time.now)
        helper.job_duration(job).should == '5s'
      end
    
      it "should format a job with a duration of N minutes as 'Nm'" do
        job = Fabricate.build(:job, :start_time => (Time.now - 60), :end_time => Time.now)
        helper.job_duration(job).should == '1m'
      end

      it "should format a job with a duration of N minutes and X seconds as 'Nm Xs'" do
        job = Fabricate.build(:job, :start_time => (Time.now - 61), :end_time => Time.now)
        helper.job_duration(job).should == '1m 1s'
      end
      
      it "should format a job with N hours as 'Nh'" do
        job = Fabricate.build(:job, :start_time => (Time.now - (60*60)), :end_time => Time.now)
        helper.job_duration(job).should == '1h'        
      end
      
      it "should format a job with N hours and X minutes as 'Nh Xm'" do
        job = Fabricate.build(:job, :start_time => (Time.now - (60 + (60*60))), :end_time => Time.now)
        helper.job_duration(job).should == '1h 1m'
      end
      
      it "should discard seconds when a job duration has hours, minutes, and seconds" do
        job = Fabricate.build(:job, :start_time => (Time.now - (61 + (60*60))), :end_time => Time.now)
        helper.job_duration(job).should == '1h 1m'
      end
      
      it "should return nil when a job has not started" do
        job = Fabricate.build(:job, :start_time => (Time.now - (61 + (60*60))), :end_time => Time.now)
        helper.job_duration(job).should == '1h 1m'
      end
      
      it "should return a duration even when there's no end time" do
        job = Fabricate.build( :job, :start_time => (Time.now - (60) ) )
        helper.job_duration(job).should == '1m'
      end
      
    end
    
  end

end
