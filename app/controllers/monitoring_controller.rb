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
    jbs = Job.slo_core_hours.joins(job_group: :hive_queue)
            
    @description = "Breakdown of job status between 9:00 and 17:00 on #{1.day.ago.strftime('%A %d %B %Y')}"
    if jbs.count > 0

      @job_queue_data = [ parse_job_status('All queues', jbs) ]
      @job_project_data = [ parse_job_projects_status('All projects', -1, jbs) ]

      by_group = jbs.group_by{|j| j.job_group.hive_queue}
      by_project = jbs.group_by{|j| j.project}

      @tmp_data = []
      by_group.each_pair do |q, data|
        @tmp_data << parse_job_status(q.name, data)
      end

      @job_queue_data = @job_queue_data + @tmp_data.sort{ |a, b| a[:queue] <=> b[:queue] }

      @tmp_data = []
      by_project.each_pair do |p, data|
        @tmp_data << parse_job_projects_status(p.name, p.id, data)
      end

      @job_project_data = @job_project_data + @tmp_data.sort{ |a, b| a[:project] <=> b[:project] }
    else
      @job_queue_data = []
      @job_project_data = []
    end
  end

  def job_status_project_graph
    respond_to do |format|
      format.html do
      end
      format.json do
        where = 'jobs.created_at > ? AND state = ?'
        where_opts = [ 31.days.ago, 'complete' ]
        if params[:project_id].to_i > 0
          where += ' AND project_id = ?'
          where_opts << params[:project_id]
        end

        data = {}
        Job.joins(:batch)
              .where([where, where_opts].flatten)
              .group('date(jobs.created_at)')
              .group(:result)
              .count.each_pair do |keys, count|
          data[keys[0]] = {
            date: keys[0].strftime('%F'),
            total: 0
          } if not data.has_key? keys[0]
          data[keys[0]][keys[1].to_sym] = count
          data[keys[0]][:total] += count
        end

        render json: data.values.map { |row|
          {
            date: row[:date],
            passed: 100.0 * row[:passed].to_f / row[:total],
            failed: 100.0 * row[:failed].to_f / row[:total],
            errored: 100.0 * row[:errored].to_f / row[:total]
          }
        }
      end
    end
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
    }
  end

  def parse_job_projects_status project, project_id, data
    not_cancelled = data.select { |d| d.status != 'cancelled' }
    qd = not_cancelled.select{ |d| d.start_time == nil }
    results = {}
    [ 'passed', 'failed', 'errored' ].each do |r|
      results[r] = not_cancelled.select{ |d| d.status == r }
    end
    {
      project: project,
      project_id: project_id,
      count: data.count,
      cancelled: data.count - not_cancelled.count,
      pc_queued: 100.0 * qd.count / not_cancelled.count,
      passed: results['passed'].count,
      passed_pc: 100.0 * results['passed'].count / data.count,
      failed: results['failed'].count,
      failed_pc: 100.0 * results['failed'].count / data.count,
      errored: results['errored'].count,
      errored_pc: 100.0 * results['errored'].count / data.count,
    }
  end

end
