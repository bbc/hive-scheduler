class MonitoringController < ApplicationController
  
  def dashboard
    # This callback is very expensive, turn it off when execution_variables aren't important
    Project.skip_callback( :initialize, :after, :set_default_execution_variables )
    
    @queues = HiveQueue.joins(:workers).where("workers.updated_at > ?", 5.minutes.ago).uniq
    
    @queued_jobs = Job.includes(:job_group => [:hive_queue], :script => [:target]).where(state: [:queued, :reserved, :running] ).order(created_at: :asc).group_by { |j| j.job_group.hive_queue }
 
    @queues = @queues.sort { |a,b| ( @queued_jobs[b] ? @queued_jobs[b].count : 0) <=> (@queued_jobs[a] ? @queued_jobs[a].count : 0) }
    
    @queues_with_no_workers = @queued_jobs.select {|q, j| !@queues.include? q }.keys
  end
  
  def workers
    Project.skip_callback( :initialize, :after, :set_default_execution_variables )
    @workers = Worker.where("updated_at > ?", 5.minutes.ago)
  end
  
  def cancel_jobs
    hive_queue_id = params[:hive_queue_id]
    
    jobs = Job.joins(:job_group).where( "job_groups.hive_queue_id = ? ", hive_queue_id ).where( state:  [:queued, :reserved, :running]  )
    
    jobs.each {|j| j.cancel }
    
    redirect_to "/queues"
  end
  
  def usage
    @batch_count_url = usage_batch_counts_path
  end
  
  def batch_counts
    months = params[:months].to_i == 0 ? 24 : params[:months].to_i
    @monthly_counts = Hive::UsageCounts.batch_counts( months: months )
  end
  
  def project_counts
    months = params[:months].to_i == 0 ? 18 : params[:months].to_i
    @project_counts = Hive::UsageCounts.project_counts( months: months )
  end
  
  def device_hours
    days = params[:days].to_i == 0 ? 6 : params[:days].to_i
    @device_hours = Hive::UsageCounts.device_hours( days: days )
  end

  def job_status
    day = 1.day.ago
    jbs = Job.joins(job_group: :hive_queue)
            .where("jobs.created_at < ? AND jobs.created_at >= ?",
                        day.change(hour: 17, minute: 0, second: 0),
                        day.change(hour: 9, minute: 0, second: 0))

    @description = "Time to start jobs by queue between 9:00 and 17:00 on #{day.strftime('%A %d %B %Y')}"

    @job_status_data = [ parse_job_status('All queues', jbs) ]

    grpd = jbs.group_by{|j| j.job_group.hive_queue}

    @tmp_data = []
    grpd.each_pair do |q, data|
      @tmp_data << parse_job_status(q.name, data)
    end

    @job_status_data = @job_status_data + @tmp_data.sort{ |a, b| a[:queue] <=> b[:queue] }
  end

  private
  def parse_job_status queue, data
    not_cancelled = data.select { |d| d.status != 'cancelled' }
    qd = not_cancelled.select{ |d| d.start_time == nil }
    one_min = not_cancelled.select{ |d| d.start_time and d.start_time - d.created_at < 1.minute }
    two_min = not_cancelled.select{ |d| d.start_time and d.start_time - d.created_at < 2.minute }
    twenty_mins = not_cancelled.select{ |d| d.start_time and d.start_time - d.created_at < 20.minutes }
    results = {}
    [ 'passed', 'failed', 'errored' ].each do |r|
      results[r] = not_cancelled.select{ |d| d.status == r }
    end
    {
      queue: queue,
      count: data.count,
      cancelled: data.count - not_cancelled.count,
      pc_queued: 100.0 * qd.count / not_cancelled.count,
      pc_1_min: 100.0 * one_min.count / not_cancelled.count,
      pc_2_min: 100.0 * two_min.count / not_cancelled.count,
      pc_20_min: 100.0 * twenty_mins.count / not_cancelled.count,
      passed: results['passed'].count,
      passed_pc: 100.0 * results['passed'].count / data.count,
      failed: results['failed'].count,
      failed_pc: 100.0 * results['failed'].count / data.count,
      errored: results['errored'].count,
      errored_pc: 100.0 * results['errored'].count / data.count,
    }
  end
  
end
