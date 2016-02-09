class Batch < ActiveRecord::Base
  module BatchScopes
    extend ActiveSupport::Concern

    included do
      
    end

    def latest_jobs
      if !@latest_jobs_cache
        @latest_jobs_cache = self.jobs.where.not(
          id: Job
              .joins("INNER JOIN jobs AS linked_jobs ON jobs.id = linked_jobs.original_job_id")
              .joins(:job_group)  # avoid full table scan on inner query by constraining it to the relevant batch
              .where(job_groups: { batch_id: self.id })
        )
      end
      @latest_jobs_cache
    end
  end
end
