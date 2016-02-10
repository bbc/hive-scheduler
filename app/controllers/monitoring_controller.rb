class MonitoringController < ApplicationController
  
  def dashboard
    
    # This callback is very expensive, turn it off when execution_variables aren't important
    Project.skip_callback( :initialize, :after, :set_default_execution_variables )
    
    @queues = Job.includes(:job_group).where(state: [:queued, :reserved, :running] ).order(created_at: :asc).group_by { |j| j.queue_name }
  end
  
end
