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

  #
  # This method does nothing in the app -- in fact it won't work
  # but it's required for a tricky migration
  #
  def read_queue_name_attribute
    attribute(:queue_name)
  end
  
end
