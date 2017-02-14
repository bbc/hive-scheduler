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
    jbs = Job.joins(job_group: :hive_queue).where("jobs.created_at < ? AND jobs.created_at >= ?", 1.minute.ago, (1.minute + 24.hours).ago)

    total = jbs.count
    not_queued = jbs.where.not(start_time: nil)
    one_minute = not_queued.where("start_time <= jobs.created_at + ?", 1.minute)
    twenty_minutes = not_queued.where("start_time <= jobs.created_at + ?", 20.minutes)

    @job_status_data = [
      {
        queue: 'overall',
        count: total,
        pc_queued: 100.0 * (total - not_queued.count)/total,
        pc_1_min: 100.0 * one_minute.count/total,
        pc_20_min: 100.0 * twenty_minutes.count/total,
      }
    ]

    grpd = jbs.group_by{|j| j.job_group.hive_queue}

    @tmp_data = []
    grpd.each_pair do |q, data|
      @tmp_data << {
        queue: q.name,
        count: data.count,
        pc_queued: 100.0 * data.select{|d| d.start_time == nil }.count/data.count,
        pc_1_min: 100.0 * data.select{|d| d.start_time and d.start_time - d.created_at < 1.minute }.count/data.count,
        pc_20_min: 100.0 * data.select{|d| d.start_time and d.start_time - d.created_at < 20.minutes }.count/data.count,
      }
    end

    @job_status_data = @job_status_data + @tmp_data.sort{ |a, b| a[:queue] <=> b[:queue] }
  end
  
end
