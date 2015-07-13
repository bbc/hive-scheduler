class QueuesController < ApplicationController
  
  def dashboard
    @queues = Job.includes(:job_group).where(state: [:queued, :reserved, :running] ).order(created_at: :asc).group_by { |j| j.queue_name }
  end
  
end
