module JobCommands

  class AutoJobRetrier < Imperator::Command

    attribute :job, Job

    action do
      job.retry unless maximum_retries_exceeded?
    end

    private

    def maximum_retries_exceeded?
      max_retries = job.batch.execution_variables['retries'].to_i > Chamber.env.maximum_auto_retries ? job.batch.execution_variables['retries'].to_i : Chamber.env.maximum_auto_retries 
      total_number_of_retries >= max_retries
    end

    def total_number_of_retries
      retries = 0
      current_job = job
      while current_job.original_job.present? do
        retries = retries+1
        current_job = current_job.original_job
      end
      retries
    end
  end
end
