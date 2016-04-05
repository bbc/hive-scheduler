class Job < ActiveRecord::Base
  module JobTestCases
    extend ActiveSupport::Concern

    def associate_test_cases(*test_names)
      test_names.each do |t|
        self.associate_test_case_result( name: t, status: 'notrun' )
        #tc = TestCase.find_or_create_by_test_name(t, project_id)
        #TestResult.create( job_id: self.id, status: 'notrun', test_case_id: tc.id )
      end
    end
    
    def associate_test_case_result( name: nil, urn: nil, status: 'unknown' )
      
      project_id = self.job_group.batch.project_id
      
      #1 Find the test case
      # 1.1 Have bother name and urn

      #i Find by name and urn
      if tc = TestCase.where( name: name, urn: urn, project_id: project_id ).first
        # Don't do anything
      
      #ii Find by name and empty urn; update urn
      elsif tc = TestCase.where( name: name, urn: nil, project_id: project_id ).first
        tc.update(urn: urn) if urn
      
      #iii Find by urn and empty name; update name (is this likely to happen?)
      elsif tc = TestCase.where(name: nil, urn: urn, project_id: project_id).first
        tc.update(name: name)
      
      #iv Create from name and urn
      else
        tc = TestCase.create( name: name, project_id: project_id, urn: urn )
      end
        
      raise "Couldn't find or create TestCase" if !tc
      
      #2 Associate result with test case
      tr = TestResult.where( job_id: self.id, test_case_id: tc.id ).last
      if tr && ( tr.status == 'notrun' || tr.status == 'running' )
        #i Find existing result and update
        tr.update(status: status)
      else
        #ii Create new result
        tr = TestResult.create( job_id: self.id, status: status, test_case_id: tc.id )
      end
      tr
    end
    
    def retriable_test_cases
      test_results.select { |tr| tr.status != 'passed' }.collect { |tr|  tr.test_case}
    end
  end
end
