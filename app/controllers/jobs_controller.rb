class JobsController < ApplicationController
  def show
    @job = Job.includes(:batch).find(params[:id])
    @message = @job.message
    render :layout => 'scrollspy_menu'
  end

  def retry
    job = Job.find(params[:job_id])
    job.retry
    redirect_to batch_path(job.batch, anchor: "job_#{job.id}")
  end
  
  def cancel
    job = Job.find(params[:job_id])
    job.cancel
    redirect_to batch_path(job.batch, anchor: "job_#{job.id}")
  end
  
end
