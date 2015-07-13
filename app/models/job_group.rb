class JobGroup < ActiveRecord::Base
  include JobGroupAssociations
  include JobGroupValidations
  include JobGroupScopes

  serialize :execution_variables, JSON
  
  def status
    ordered_job_states = [:running, :queued, :reserved, :errored, :failed, :passed, :complete, :analyzing, :preparing, :retried, :cancelled]
    job_states         = latest_jobs.collect { |job| job.status.to_sym }.uniq
    job_states = job_states.sort_by { |state| ordered_job_states.index(state) }
    job_states.find do |state|
      ordered_job_states.include?(state)
    end || :invalid
  end
  
end
