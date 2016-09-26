module JobCommands
  class JobMessageMapper < Imperator::Command
    include Rails.application.routes.url_helpers

    attribute :job, Job

    validates_presence_of :job

    action do
      Hive::Messages::Job.new(job.attributes.merge(job_message_attributes))
    end


    private

    def job_message_attributes
      {
          command:             command,
          execution_variables: execution_variables,
          job_id:              job_id,
          repository:          repository,
          execution_directory: execution_directory,
          target:              target,
          test_results:        test_results,
          log_files:           log_files,
      }
    end

    def command
      script.template
    end

    def job_id
      job.id
    end

    def execution_directory
      batch.project.execution_directory
    end

    def target
      job.target
    end

    def execution_variables
      if @execution_variables.nil?
        @execution_variables = { version: batch.version, job_id: job.id, queue_name: job_group.queue_name }
        [batch, job_group, job].each do |model|
          @execution_variables.merge!(model.execution_variables) if model.execution_variables.present?
        end
        @execution_variables[:retry_urns] = retry_urns if retry_urns
      end
      @execution_variables
    end
    
    def retry_urns
      job.retriable_test_cases.collect { |t| t.urn }.compact
    end

    def repository
      batch.project.repository
    end

    def target
      target = batch.target_information || {}
      target.merge!(build: api_batch_download_build_path(batch.id)) if script.requires_build?
      target
    end

    def batch
      job.batch
    end

    def job_group
      job.job_group
    end

    def script
      job.script
    end

    def test_results
      if @test_results.nil?
        @test_results = []
        job.test_results.each do |result|
          @test_results << {
            test_case: result.test_case.name,
            urn: result.test_case.urn,
            status: result.status
          }
        end
      end
      @test_results
    end

    def log_files
      if @log_files.nil?
        @log_files = {}
        job.log_files.each do |log_name, log_url|
          @log_files[log_name] = log_url
        end
      end
      @log_files
    end
  end
end
