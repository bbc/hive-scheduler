module JobCommands
  class JobResultsUpdater < Imperator::Command

    attribute :job_id
    attribute :running_count, Integer
    attribute :passed_count, Integer
    attribute :failed_count, Integer
    attribute :errored_count, Integer
    attribute :result_details, String

    validates_presence_of :job_id

    action do
      job.update(updated_counts)
      
      # Populate test results
      parsed_result_details.each do |r|
        job.associate_test_case_result( name: r['name'], urn: r['urn'], status: r['status'])
      end
      
      job
    end

    private

    def job
      @job ||= Job.find(job_id)
    end

    def updated_counts
      attributes.slice(:running_count, :passed_count, :failed_count, :errored_count).delete_if { |k, v| v.nil? }
    end
    
    def parsed_result_details
      result_details ? JSON.parse(result_details) : []
    end
    
  end
end
