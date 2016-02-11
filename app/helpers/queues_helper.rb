module QueuesHelper
  
  def job_span(job)    
    html = %Q{<a id="job-#{job.id}" href="#{job_url(job)}" data-toggle="tooltip" title="Job #{job.id}"><span class="label label-#{job.state}"><span class='job-icon'>#{icon(job.script.target.icon)}</span></span></a>}
    
    html += %Q{<script>$('#job-#{job.id}').tooltip({"animation": true })</script>}
    
    html.html_safe
  end
  
end
