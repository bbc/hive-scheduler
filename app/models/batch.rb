class Batch < ActiveRecord::Base
  include BatchValidations
  include BatchChart
  include BatchAssociations
  include BatchScopes

  serialize :target_information, JSON
  serialize :execution_variables, JSON

  delegate :requires_build?, to: :project, allow_nil: true
  delegate :execution_variables_required, to: :project, allow_nil: true

  self.per_page = 20

  default_value_for :number_of_automatic_retries, 1

  after_initialize :copy_execution_variables

  def copy_execution_variables
    if self.new_record? && self.project.present?
      execution_variables = (self.execution_variables || {}).delete_if { |_, value| value.blank? }
      self.execution_variables = (self.project.execution_variables || {}).merge(execution_variables)
    end
  end

  def tests_per_job
    execution_variables.with_indifferent_access[:tests_per_job].to_i
  end

  def jobs_per_queue
    execution_variables.with_indifferent_access[:jobs_per_queue]
  end

  def state
    if !@state_cache
      ordered_job_states = [:running, :queued, :errored, :failed, :passed, :complete, :analyzing, :preparing, :retried, :cancelled]
      job_states         = latest_jobs.collect { |job| job.status.to_sym }.uniq
      job_states.delete(:reserved)
      job_states = job_states.sort_by { |state| ordered_job_states.index(state) }
      @state_cache = job_states.find do |state|
        ordered_job_states.include?(state)
      end || :invalid
    end
    @state_cache
  end
  
  def test_result_count_hash
    if !@hash
      @hash = job_groups.collect { |g| g.test_results.group_by {|tr| tr.test_case_id}.collect { |k,v| v.last } }.flatten.group_by { |t| t.status }
      @hash['queued'] = @hash['notrun']
    end
    @hash
  end
  
  def active_job_states( state, result )
    if !@active_job_states
      @active_job_states = jobs.active.group('jobs.state').group('jobs.result').count
    end
    @active_job_states[[state, result]] || 0
  end
 
  #
  # These methods provide a summary of the job statuses
  #
  def jobs_queued
    active_job_states("queued", nil) + active_job_states("pending", nil)
  end

  def jobs_running
    active_job_states( "preparing", nil ) + active_job_states( "running", nil ) + active_job_states( "analyzing", nil )
  end

  def jobs_passed
    active_job_states( "complete", "passed" )
  end

  def jobs_failed
    active_job_states( "complete", "failed" )
  end
  
  def jobs_errored
    jobs.active.where("jobs.state='errored' or jobs.state='cancelled' or ( jobs.state='complete' and jobs.result='errored')" ).count
  end
  

  def assets
    project_assets.where(version: self.version).group_by { |a| a.asset_file_name }.collect { |k,v| v.first }
  end

  #
  # These methods give a total count of all tests in the batch
  #
  [:queued, :running, :passed, :failed, :errored].each do |m|
    define_method("tests_#{m}") do
      if !test_cases.empty?
        (test_result_count_hash[m.to_s] || []).count
      else      
        jobs.active.sum("#{m}_count")
      end
    end
  end
  
end
