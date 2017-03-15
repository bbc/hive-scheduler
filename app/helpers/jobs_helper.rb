module JobsHelper
  def full_job_name(job)
    name = truncate(job.job_name, :length => 50)
    name << " [Retry ##{job.retry_count}]" if job.retry_count > 0
    return name
  end
  
  def script_duration(job)
    if job.script_start_time
      duration = (job.script_end_time ? job.script_end_time : Time.now) - job.script_start_time
      formulate_duration duration
    end
  end

  def job_duration(job)
    if job.start_time
      duration = (job.end_time ? job.end_time : Time.now) - job.start_time
      formulate_duration duration
    end
  end

  def formulate_duration duration
      hours   = (duration / (60*60)).to_i
      minutes = ((duration - hours*60*60) / (60)).to_i
      seconds = (duration % 60).to_i
      
      components = []
      components << "#{hours}h" if hours > 0
      components << "#{minutes}m" if minutes > 0
      components << "#{seconds}s" if ( seconds > 0 && components.length < 2 )
      
      components.join(" ")
  end

  def device_name_db_link(job)
    details = job.device_details
    if job.device_details && job.device_details["name"]
      "<a href='#{Rails.application.config.hive_mind_url}/devices/#{details['id']}'>#{details['name']} (#{details['brand']} #{details['model']})</a>".html_safe
    end
  end
  
end
